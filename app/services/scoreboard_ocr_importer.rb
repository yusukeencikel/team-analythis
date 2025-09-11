require 'net/http'
require 'uri'
require 'json'
require 'base64'

class ScoreboardOcrImporter
  def initialize(image_file:)
    @image_file = image_file
    @api_key = ENV['GEMINI_API_KEY']
    unless @api_key
      raise "Gemini APIキーが見つかりません。.envファイルに 'GEMINI_API_KEY' を設定してください。"
    end
  end

  def extract_scores
    prompt = create_prompt
    response_json = call_gemini_api(@image_file, prompt)
    
    Rails.logger.info "--- Gemini Scoreboard OCR Response ---"
    Rails.logger.info response_json.inspect
    Rails.logger.info "------------------------------------"

    response_json
  end

  private

  def create_prompt
    <<~PROMPT
    あなたは、野球のスコアボード画像を解析し、構造化されたJSONデータを出力することに特化した、高精度なAIアシスタントです。

    あなたの唯一のタスクは、提供された画像からスコア情報を抽出し、以下のルールに厳密に従ってJSONオブジェクトを生成することです。

    【絶対的なルール】
    1.  **出力は、MarkdownのJSONコードブロック内に記述された、有効なJSONオブジェクトのみ**とします。
    2.  JSONコードブロックの前後には、挨拶、説明、注釈など、**いかなるテキストも絶対に追加してはいけません**。
    3.  画像の上段チームを `top_team`、下段チームを `bottom_team` とします。
    4.  各チームのイニングごとの得点は `score_details` 配列に格納します。延長戦もすべて含めてください。
    5.  スコアが書かれていないイニング、`0`点のイニング、サヨナラゲームの "X" は、すべて数値の `0` として扱います。
    6.  **合計得点(R)は抽出せず**、安打数(H)、失策数(E)は `hits`, `errors` として抽出します。
    7.  全ての項目において、値が不明、または読み取れない場合は `null` ではなく、必ず数値の `0` を返してください。

    【出力フォーマット】
    ```json
    {
      "top_team": {
        "score_details": [0, 0, 0, 0, 0, 0, 0, 0, 0],
        "hits": 4,
        "errors": 1
      },
      "bottom_team": {
        "score_details": [0, 1, 0, 0, 2, 0, 0, 1, 0],
        "hits": 8,
        "errors": 1
      }
    }
    ```
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
      http.read_timeout = 60
      http.open_timeout = 60

      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.body = request_body.to_json
      response = http.request(request)
      
      Rails.logger.info "--- Raw API Response Body ---"
      Rails.logger.info response.body
      Rails.logger.info "-----------------------------"
      
      response_body = JSON.parse(response.body)

      if response_body.key?('error')
        Rails.logger.error "Gemini APIエラー: #{response_body['error']['message']}"
        return {}
      end

      candidate = response_body['candidates']&.first
      raw_text = candidate&.dig('content', 'parts', 0, 'text').to_s
      
      json_string = raw_text.match(/```json\s*(\{.*\})\s*```/m)&.[](1)

      if json_string.present?
        data = JSON.parse(json_string)
        return sanitize_ocr_data(data)
      else
        Rails.logger.warn "Gemini APIから期待したJSON形式のデータが返されませんでした。"
        Rails.logger.warn "Raw Response: #{raw_text}"
        return {}
      end
    rescue JSON::ParserError => e
      Rails.logger.error "JSONの解析に失敗しました: #{e.message}"
      Rails.logger.error "不正なJSON文字列: #{json_string || response.body}"
      return {}
    rescue => e
      Rails.logger.error "Gemini APIの呼び出しでエラーが発生しました: #{e.class.name} - #{e.message}"
      return {}
    end
  end

  def sanitize_ocr_data(data)
    ['top_team', 'bottom_team'].each do |team_key|
      if data[team_key].is_a?(Hash)
        team_data = data[team_key]
        
        if team_data['score_details'].is_a?(Array)
          team_data['score_details'].map! { |score| score.to_i }
        else
          team_data['score_details'] = []
        end

        ['hits', 'errors'].each do |stat_key|
          team_data[stat_key] = team_data[stat_key].to_i
        end
      end
    end
    data
  end
end