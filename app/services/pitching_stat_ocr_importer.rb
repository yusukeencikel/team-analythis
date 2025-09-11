require 'net/http'
require 'uri'
require 'json'
require 'base64'

class PitchingStatOcrImporter
  def initialize(image_files:)
    @image_files = image_files
    @api_key = ENV['GEMINI_API_KEY']
    unless @api_key
      raise "Gemini APIキーが見つかりません。.envファイルに 'GEMINI_API_KEY' を設定してください。"
    end
  end

  def extract_stats
    all_player_stats = []
    @image_files.each do |image_file|
      prompt = create_prompt
      response_json = call_gemini_api(image_file, prompt)
      next if response_json.empty?

      # Geminiからの出力をRuby側でパースして、投球回を正確な小数に変換する
      response_json.each do |stat|
        raw_innings = stat['innings_pitched']
        stat['innings_pitched'] = parse_innings_pitched(raw_innings)
      end

      all_player_stats.concat(response_json)
    end
    merged_stats = merge_duplicate_pitchers(all_player_stats)
    auto_register_new_players(merged_stats)
    merged_stats
  end

  private

  # 投球回の文字列 ("7 2/3"など) を小数 (7.2など) に変換するメソッド
  def parse_innings_pitched(text)
    return text unless text.is_a?(String)

    cleaned_text = text.strip.tr('　', ' ').delete('回')
    innings = 0.0

    if cleaned_text.include?('1/3')
      innings += 0.1
      integer_part = cleaned_text.gsub('1/3', '').to_f
      innings += integer_part
    elsif cleaned_text.include?('2/3')
      innings += 0.2
      integer_part = cleaned_text.gsub('2/3', '').to_f
      innings += integer_part
    else
      innings = cleaned_text.to_f
    end

    innings.round(1)
  end

  def create_prompt
    <<~PROMPT
      あなたはプロの野球アナリスト兼OCRエキスパートです。
      この画像は、野球の試合における投手の個人成績がまとめられたスコアボードのスクリーンショットです。
      画像の中から、各選手の成績を抽出し、指定されたJSON形式で返してください。

      【厳密な抽出ルール】
      1. 各行から「選手名」「投球回」「対戦打者数」「投球数」「被安打」「奪三振」「四球」「死球」「失点」「自責点」「暴投」「被本塁打」を読み取ってください。
      2. **重要：投球回は、画像に表示されている通り、分数を含んだままの文字列として抽出してください。**
         - 例: 「7回2/3」なら `"7 2/3"`、「1回1/3」なら `"1 1/3"`、整数の場合は `"8"` のように抽出します。
         - **小数への変換は絶対にしないでください。**
      3. 選手名の左にある「勝」「敗」「H」「S」の文字を認識し、`"pitcher_result"`として「勝利」「敗戦」「ホールド」「セーブ」のいずれかを設定してください。該当しない場合は空文字列 `""` を返してください。
      4. 登板した順番（上から順）に `"pitching_order"` として 1, 2, 3... と番号を振ってください。一番上の投手が1です。
      5. 選手名は、隣接する文字を結合して、一つの正しい名前にしてください。
      6. 抽出した結果を、以下のJSON形式の配列としてのみ返してください。他の説明や前置きは一切不要です。

        [
          { "player_name": "選手名A", "pitching_order": "1", "pitcher_result": "勝利", "innings_pitched": "7 2/3", "batters_faced": "28", "pitches_thrown": "110", "hits_allowed": "5", "strikeouts": "9", "walks": "2", "hit_by_pitches": "0", "runs_allowed": "1", "earned_runs": "1", "wild_pitches": "0", "home_runs_allowed": "1" },
          { "player_name": "選手名B", "pitching_order": "2", "pitcher_result": "ホールド", "innings_pitched": "1/3", "batters_faced": "3", "pitches_thrown": "15", "hits_allowed": "0", "strikeouts": "2", "walks": "0", "hit_by_pitches": "0", "runs_allowed": "0", "earned_runs": "0", "wild_pitches": "0", "home_runs_allowed": "0" }
        ]
      PROMPT
  end

  def call_gemini_api(image_file, prompt)
    uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=#{@api_key}")
    image_data = image_file.read
    image_file.rewind if image_file.respond_to?(:rewind)
    request_body = {
      contents: [{
        parts: [
          { text: prompt },
          { inline_data: { mime_type: image_file.content_type, data: Base64.strict_encode64(image_data) } }
        ]
      }]
    }

    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.body = request_body.to_json
      response = http.request(request)

      puts "--- Gemini API Raw Response ---"
      puts response.body
      puts "-----------------------------"

      response_body = JSON.parse(response.body)

      if response_body.key?('error')
        Rails.logger.error "Gemini APIエラー: #{response_body['error']['message']}"
        return []
      end

      candidate = response_body['candidates']&.first
      generated_text = candidate&.dig('content', 'parts', 0, 'text')
      puts "--- Generated Text from Gemini ---"
      puts generated_text
      puts "----------------------------------"

      json_string = generated_text&.match(/(\[.*\])/m)&.[](1)

      return json_string.present? ? JSON.parse(json_string) : []
    rescue => e
      puts "--- Error during API call ---"
      puts "Error Class: #{e.class.name}"
      puts "Error Message: #{e.message}"
      puts "-----------------------------"
      Rails.logger.error "Gemini APIの呼び出しでエラーが発生しました: #{e.class.name} - #{e.message}"
      return []
    end
  end

  def merge_duplicate_pitchers(stats)
    merged = {}
    stats.each do |stat|
      name = stat['player_name']
      merged[name] = stat
    end
    merged.values
  end

  def auto_register_new_players(stats)
    stats.each do |stat|
      player_name = stat['player_name']
      next if player_name.blank?

      unless Player.exists?(name: player_name)
        temp_jersey_number = Time.now.to_i.to_s
        Player.create(
          name: player_name, 
          position: "投手", 
          jersey_number: temp_jersey_number
        )
      end
    end
  end
end
