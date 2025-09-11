require 'net/http'
require 'uri'
require 'json'
require 'base64'

class PlayerOcrImporter
  def initialize(image_file:)
    @image_file = image_file
    @api_key = ENV['GEMINI_API_KEY']
    unless @api_key
      raise "Gemini APIキーが見つかりません。.envファイルに 'GEMINI_API_KEY' を設定してください。"
    end
  end

  def extract_players
    prompt = <<~PROMPT
      あなたはプロのOCRアナリストです。
    この画像は、野球選手の選手名簿のスクリーンショットで、選手名の左側にポジションを示す色付きのマークがあります。

     【重要な色判別ルール】
    以下の色とポジションの対応関係を厳密に適用してください：
    - 赤系 (rgb(232,141,137) に近い色): 投手
    - 青/紫系 (rgb(155,161,220) に近い色): 捕手  
    - 黄系 (rgb(218,192,98) に近い色): 内野手
    - 緑系 (rgb(110,191,128) に近い色): 外野手

     【抽出ルール】
    1. 表形式で表示されている選手名と背番号のペアをすべて抽出してください
    2. 各選手名の左側にある色マークを注意深く観察し、上記の色判別ルールに基づいてポジションを判定してください
    3. 「OK」「リセット」「新しい背番号」「FPS」「背番号設定」のようなUI要素は無視してください
    4. 選手名は完全な形に修正してください（例：「リルバーン」を「リルバーン」に）
    5. 背番号が「00」の場合はそのまま「00」として保持してください
    6. 抽出した結果を、以下のJSON形式の配列としてのみ返してください。他の説明や前置きは一切不要です。

      [
        { "name": "選手名1", "jersey_number": "背番号1", "position": "投手" },
        { "name": "選手名2", "jersey_number": "背番号2", "position": "捕手" },
        { "name": "選手名3", "jersey_number": "背番号3", "position": "内野手" },
        { "name": "選手名4", "jersey_number": "背番号4", "position": "外野手" }
      ]
    PROMPT

    # 正しいモデル名とエンドポイントを使用
    uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=#{@api_key}")
    
    # ファイルデータを読み取り
    image_data = @image_file.read
    @image_file.rewind if @image_file.respond_to?(:rewind)

    request_body = {
      contents: [
        {
          parts: [
            { text: prompt },
            {
              inline_data: {
                mime_type: @image_file.content_type,
                data: Base64.strict_encode64(image_data)
              }
            }
          ]
        }
      ]
    }

    # Net::HTTPでPOSTリクエストを送信
    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.body = request_body.to_json

      response = http.request(request)
      response_body = JSON.parse(response.body)

      # エラーチェックを追加
      if response_body.key?('error')
        puts "Gemini APIエラー: #{response_body['error']['message']}"
        return []
      end

      candidate = response_body['candidates']&.first
      json_string = candidate&.dig('content', 'parts', 0, 'text')&.match(/\[.*\]/m).to_s
      
      if !json_string.empty?
        parsed_json = JSON.parse(json_string)
        players_data = parsed_json.map do |player_hash|
          { 
            'name' => player_hash['name'], 
            'jersey_number' => player_hash['jersey_number'],
            'position' => player_hash['position'] || '不明'
          }
        end
        return players_data.sort_by { |p| p['jersey_number'].to_i }
      else
        puts "Gemini APIからの応答に有効なJSONが含まれていませんでした。"
        puts "Geminiからの応答全文: #{response_body}"
        return []
      end

    rescue JSON::ParserError => e
      puts "Gemini APIからのJSON解析に失敗しました: #{e.message}"
      return []
    rescue => e
      puts "Gemini APIの呼び出しでエラーが発生しました: #{e.class.name} - #{e.message}"
      return []
    end
  end
end