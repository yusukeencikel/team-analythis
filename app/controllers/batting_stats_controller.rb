class BattingStatsController < ApplicationController
  before_action :set_game

  def show
    @players = Player.where(status: 'active').order(:jersey_number)
    @best_orders = BestOrder.all.order(:name)
    @batting_stats = @game.batting_stats.includes(:player).order(:batting_order, :participation_type)
    
    # ▼▼▼【ここから追記】▼▼▼
    ocr_result_id = params[:ocr_result_id]
    if ocr_result_id
      # セキュリティのため、現在のセッションIDと一致するものだけを検索
      ocr_result = OcrResult.find_by(id: ocr_result_id, session_key: session.id.to_s)
      if ocr_result
        @ocr_data = ocr_result.data
        ocr_result.destroy # データを渡したら、一時データはすぐに削除する
      end
    end
    # ▲▲▲【ここまで追記】▲▲▲
  end

  def create
    @game.batting_stats.destroy_all # 一度、その試合の全野手成績をリセット
    if params[:batting_stats].present?
      batting_stats_params.each do |stats|
        # 選手が選択されていない行は無視
        next if stats[:player_id].blank?
        @game.batting_stats.create(stats)
      end
    end
    redirect_to @game, notice: '野手成績を保存しました。'
  end
  
  private

  def set_game
    @game = Game.find(params[:game_id])
  end

  def batting_stats_params
    # :player_id を許可リストに追加
    params.require(:batting_stats).values.map do |stats|
      stats.permit(
        :player_id, :batting_order, :participation_type, :fielding_position,
        :at_bats, :hits, :doubles, :triples, :home_runs, :rbi, :runs,
        :strikeouts, :walks, :sacrifice_bunts, :sacrifice_flies,
        :stolen_bases, :double_plays, :fielding_errors
      )
    end
  end
end

