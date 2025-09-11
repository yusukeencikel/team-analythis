require 'net/http'
require 'uri'
require 'json'
require 'base64'

class BattingStatOcrImporter
  def initialize(image_files:)
    @image_files = image_files
    @api_key = ENV['GEMINI_API_KEY']
    unless @api_key
      raise "Gemini APIキーが見つかりません。.envファイルに 'GEMINI_API_KEY' を設定してください。"
    end
  end

  def extract_stats
    all_player_stats = []

    # アップロードされた各画像を順番に処理
    @image_files.each do |image_file|
      prompt = create_prompt
      response_json = call_gemini_api(image_file, prompt)
      next if response_json.empty?

      all_player_stats.concat(response_json)
    end

    # 選手名で重複を排除する
    merged_stats = merge_duplicate_players(all_player_stats)
    
    # マスタに存在しない選手を自動で登録する
    auto_register_new_players(merged_stats)

    merged_stats
  end

  private

  def create_prompt
    # ▼▼▼【プロンプトを更新し、「打順」も抽出するように指示】▼▼▼
    <<~PROMPT
      あなたはプロの野球アナリスト兼OCRエキスパートです。
      この画像は、野球の試合における野手の個人成績がまとめられたスコアボードのスクリーンショットです。
      画像の中から、各選手の成績を抽出し、指定されたJSON形式で返してください。

      【厳密な抽出ルール】
      1. 各行から「打順」「選手名」「打数」「安打」「二塁打」「三塁打」「本塁打」「打点」「得点」「三振」「四球」「犠打」「盗塁」「併殺打」「失策」を読み取ってください。（犠飛は存在しません）
      2. 選手名は、隣接する文字（例：「荒」と「井」）を結合して、一つの正しい名前にしてください。
      3. 抽出した結果を、以下のJSON形式の配列としてのみ返してください。他の説明や前置きは一切不要です。

      [
        { "batting_order": "1", "player_name": "選手名A", "at_bats": "4", "hits": "2", "doubles": "1", "triples": "0", "home_runs": "0", "rbi": "1", "runs": "1", "strikeouts": "1", "walks": "0", "sacrifice_bunts": "0", "stolen_bases": "0", "double_plays": "0", "fielding_errors": "0" },
        { "player_name": "選手名B", "at_bats": "5", "hits": "1", ... }
      ]
    PROMPT
  end

  def call_gemini_api(image_file, prompt)
    uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=#{@api_key}")
    
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
      response_body = JSON.parse(response.body)

      if response_body.key?('error')
        Rails.logger.error "Gemini APIエラー: #{response_body['error']['message']}"
        return []
      end

      candidate = response_body['candidates']&.first
      json_string = candidate&.dig('content', 'parts', 0, 'text')&.match(/\[.*\]/m).to_s
      
      return json_string.present? ? JSON.parse(json_string) : []
    rescue => e
      Rails.logger.error "Gemini APIの呼び出しでエラーが発生しました: #{e.class.name} - #{e.message}"
      return []
    end
  end

  def merge_duplicate_players(stats)
    merged = {}
    stats.each do |stat|
      name = stat['player_name']
      # 2回目以降に登場した同じ名前の選手は無視する
      unless merged[name]
        merged[name] = stat
      end
    end
    merged.values
  end

  def auto_register_new_players(stats)
    stats.each do |stat|
      player_name = stat['player_name']
      next if player_name.blank?
      
      unless Player.exists?(name: player_name)
        # 仮の背番号としてタイムスタンプなどユニークな値を設定
        temp_jersey_number = "新#{Time.now.to_i % 1000}"
        Player.create(name: player_name, position: "不明", jersey_number: temp_jersey_number)
      end
    end
  end
end

