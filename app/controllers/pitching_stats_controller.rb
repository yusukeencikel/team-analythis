class PitchingStatsController < ApplicationController
  before_action :set_game
  
  def index
    # ドロップダウン選択肢用の投手リスト
    @players = Player.where(status: 'active', position: "投手").order(:jersey_number)
    
    # OCR取り込み結果がある場合はそちらを優先
    if session[:pitching_ocr_results]
      @pitching_stats = session.delete(:pitching_ocr_results).map do |stat_hash|
        PitchingStat.new(
          player_id: stat_hash['player_id'],
          pitching_order: stat_hash['pitching_order'],
          pitcher_result: stat_hash['pitcher_result'],
          innings_pitched: stat_hash['innings_pitched'],
          pitches_thrown: stat_hash['pitches_thrown'],
          hits_allowed: stat_hash['hits_allowed'],
          runs_allowed: stat_hash['runs_allowed'],
          earned_runs: stat_hash['earned_runs'],
          home_runs_allowed: stat_hash['home_runs_allowed'],
          walks: stat_hash['walks'],
          strikeouts: stat_hash['strikeouts'],
          wild_pitches: stat_hash['wild_pitches'],
          hit_by_pitches: stat_hash['hit_by_pitches']
        )
      end
    else
      # 通常の成績表示
      @pitching_stats = @game.pitching_stats.joins(:player).order(:pitching_order)
    end
  end

  def create
    @game.pitching_stats.destroy_all
    
    if params[:pitching_stats].present?
      pitching_stats_params.each do |stats_hash|
        next if stats_hash[:player_id].blank?

        stat = @game.pitching_stats.new(stats_hash)

        unless stat.save
          redirect_to game_pitching_stats_path(@game), alert: "成績の保存に失敗しました: #{stat.errors.full_messages.join(', ')}"
          return
        end
      end
    end
    redirect_to @game, notice: '投手成績を保存しました。'
  end

  def ocr_new
  end

  def ocr_create
    images = params[:images]&.reject(&:blank?)
    unless images&.any?
      redirect_to ocr_new_game_pitching_stats_path(@game), alert: "画像ファイルを選択してください。"
      return
    end

    extracted_stats = PitchingStatOcrImporter.new(image_files: images).extract_stats

    if extracted_stats.empty?
      redirect_to ocr_new_game_pitching_stats_path(@game), notice: "画像から成績を検出できませんでした。"
    else
      session[:pitching_ocr_results] = extracted_stats
      redirect_to game_pitching_stats_path(@game)
    end
  end
  
  private
  
  def set_game
    @game = Game.find(params[:game_id])
  end
  
  def pitching_stats_params
    params.require(:pitching_stats).values.map do |p|
      p.permit(
        :player_id,
        :pitching_order,
        :pitcher_result,
        :innings_pitched,
        :pitches_thrown,
        :hits_allowed,
        :runs_allowed,
        :earned_runs,
        :home_runs_allowed,
        :walks,
        :strikeouts,
        :wild_pitches,
        :hit_by_pitches
      )
    end
  end
end