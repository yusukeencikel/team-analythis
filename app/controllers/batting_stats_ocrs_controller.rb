class BattingStatsOcrsController < ApplicationController
  before_action :set_game

  def create
    images = params[:images]&.reject(&:blank?)
    unless images&.any?
      redirect_to new_game_batting_stats_ocr_path(@game), alert: "画像ファイルを選択してください。"
      return
    end

    extracted_stats = BattingStatOcrImporter.new(image_files: images).extract_stats

    if extracted_stats.empty?
      redirect_to new_game_batting_stats_ocr_path(@game), notice: "画像から成績を検出できませんでした。"
    else
      # データをDBに一時保存
      ocr_result = OcrResult.create(session_key: session.id.to_s, data: extracted_stats)
      
      # ▼▼▼【ここを修正】▼▼▼
      # 確認画面ではなく、野手成績入力画面にリダイレクト
      redirect_to game_batting_stats_path(@game, ocr_result_id: ocr_result.id)
    end
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end
end

