class PlayersController < ApplicationController
  before_action :set_player, only: [:show, :edit, :update, :destroy, :add_dummy_stats, :save_dummy_stats]

  def index
    @players = Player.where(status: 'active').order(:jersey_number)
    @grouped_players = @players.group_by(&:position)
    @position_order = ["投手", "捕手", "内野手", "外野手"]
  end

  def retired
    @players = Player.where(status: 'inactive').order(Arel.sql('CAST(jersey_number AS INTEGER) ASC NULLS LAST'))
    @grouped_players = @players.group_by(&:position)
    @position_order = ["投手", "捕手", "内野手", "外野手", nil]
    render :index
  end

  def no_jersey_number
    @players = Player.where(status: 'active').where("jersey_number IS NULL OR jersey_number = '' OR jersey_number = '-'").order(:name)
  end

  def show
    if @player.status == 'inactive' && params[:year].blank?
      params[:year] = 'career'
    end

    # 1. 表示する成績の種類を決定 ('batting' or 'pitching')
    @stats_type = params[:stats].presence || (@player.position == "投手" ? 'pitching' : 'batting')

    # 2. 表示する年を決定 ('career', 年度の数値, または nil -> 今シーズン)
    @year_param = params[:year]

    # 3. 表示年と成績タイトルを設定
    if @year_param == 'career'
      @display_year = 'career'
      @stats_title = "通算成績"
    elsif @year_param.present?
      @display_year = @year_param.to_i
      @stats_title = "#{@display_year}年シーズン成績"
    else
      @display_year = @current_season_year # ApplicationControllerで設定
      @stats_title = "今シーズン成績 (#{@display_year}年)"
    end

    # 4. 成績データを取得
    year_for_detailed_stats = (@display_year == 'career' ? nil : @display_year)

    @awards =     @awards = @player.awards.order(year: :desc)
    @awards_by_year = @awards.group_by(&:year)
    
    if @stats_type == 'pitching'
      @main_stats = @player.pitching_stats_for(@display_year) || {}
      @yearly_stats = @player.yearly_pitching_stats
      @stats_by_opponent = @player.pitching_stats_by_opponent(year: year_for_detailed_stats) || {}
      @monthly_stats = @player.pitching_monthly_stats(year: year_for_detailed_stats) || {}
      @stats_by_stadium = @player.pitching_stats_by_stadium(year: year_for_detailed_stats) || {}
      @stats_by_home_away = @player.pitching_stats_by_home_away(year: year_for_detailed_stats) || {}
      @chart_data = @player.era_progression(year_for_detailed_stats || @current_season_year) || { labels: [], data: [] }
    else # batting
      @main_stats = @player.stats_for(@display_year) || {}
      @yearly_stats = @player.yearly_batting_stats
      @stats_by_opponent = @player.stats_by_opponent(year: year_for_detailed_stats) || {}
      @monthly_stats = @player.monthly_stats(year: year_for_detailed_stats) || {}
      @stats_by_stadium = @player.stats_by_stadium(year: year_for_detailed_stats) || {}
      @stats_by_home_away = @player.stats_by_home_away(year: year_for_detailed_stats) || {}
      @chart_data = @player.batting_average_progression(year_for_detailed_stats || @current_season_year) || { labels: [], data: [] }
    end
    
    # 最近の試合
    @recent_games_stats = @stats_type == 'pitching' ? @player.pitching_stats.joins(:game).order('games.game_date DESC').limit(6) : @player.recent_games_stats(6)
  end

  def new
    @player = Player.new
  end

  def edit
  end

  def create
    @player = Player.new(player_params)
    if @player.save
      redirect_to players_url, notice: '選手を登録しました。'
    else
      render :new
    end
  end

  def update
    if @player.update(player_params)
      redirect_to @player, notice: '選手情報を更新しました。'
    else
      render :edit
    end
  end

  def destroy
    @player.destroy
    redirect_to players_url, notice: '選手を削除しました。'
  end

  def edit_all
    @players = Player.find(params[:player_ids])
  end

  def update_all
    if params[:players].blank?
      redirect_to players_url, alert: "更新する選手が選択されていません。"
      return
    end

    updated_count = 0
    error_players = []

    Player.transaction do
      params[:players].each do |id, player_params|
        player = Player.find(id)
        
        permitted_params = player_params.permit(:name, :jersey_number, :position, :throwing_hand, :batting_hand, :birthday, :status)
        
        birthday_str = permitted_params[:birthday]
        if birthday_str.present?
          if birthday_str.match?(/^\d{8}$/)
            begin
              permitted_params[:birthday] = Date.strptime(birthday_str, '%Y%m%d')
            rescue Date::Error
              player.errors.add(:birthday, 'の日付フォーマットが不正です')
            end
          else
            player.errors.add(:birthday, 'はYYYYMMDD形式で入力してください')
          end
        end

        if player.errors.empty? && player.update(permitted_params)
          updated_count += 1
        else
          error_players << player
        end
      end

      if error_players.any?
        raise ActiveRecord::Rollback
      end
    end

    if error_players.empty?
      redirect_to players_url, notice: "#{updated_count}人の選手情報を更新しました。"
    else
      @players = Player.where(id: error_players.map(&:id))
      flash.now[:alert] = "以下の選手の情報更新に失敗しました。"
      render :edit_all, status: :unprocessable_entity
    end
  end

  def destroy_all
    Player.destroy(params[:player_ids])
    redirect_to players_url, notice: "選択した選手を削除しました。"
  end

  def add_dummy_stats
    @available_years = (1900..@current_season_year).to_a.reverse
  end

  def save_dummy_stats
    year = params[:year]
    
    if year.blank?
      redirect_to add_dummy_stats_player_path(@player), alert: "年度を選択してください。"
      return
    end

    if @player.position == '投手'
      stat_params = params[:pitching_stats] || {}
      permitted_params = stat_params.permit(
        :games_pitched, :appearances, :wins, :losses, :saves, :holds, :outs_pitched, :innings_pitched,
        :hits_allowed, :home_runs_allowed, :strikeouts_pitched, :walks_pitched, :runs_allowed,
        :earned_runs, :whip, :era, :k_bb, :fip, :qs, :hqs, :starts, :complete_games,
        :shutouts, :no_walk_complete_games
      ) if stat_params.present?
    else
      stat_params = params[:batting_stats] || {}
      permitted_params = stat_params.permit(
        :games, :at_bats, :plate_appearances, :hits, :doubles, :triples, :home_runs, :total_bases,
        :rbi, :runs, :stolen_bases, :walks, :strikeouts, :sacrifice_bunts, :sacrifice_flies,
        :batting_average, :on_base_percentage, :slugging_percentage, :ops, :iso, :isod, :fielding_errors
      ) if stat_params.present?
    end

    if permitted_params.blank?
      redirect_to add_dummy_stats_player_path(@player), alert: "成績データを入力してください。"
      return
    end

    yearly_stat = YearlyStat.find_or_initialize_by(player_id: @player.id, year: year)
    yearly_stat.stats_type = @player.position == '投手' ? 'pitching' : 'batting'
    
    if yearly_stat.update(permitted_params)
      redirect_to player_path(@player, year: year), notice: "ダミー成績を保存しました。"
    else
      redirect_to add_dummy_stats_player_path(@player), alert: "成績の保存に失敗しました: #{yearly_stat.errors.full_messages.join(', ')}"
    end
  end

  private

  def set_player
    @player = Player.find(params[:id])
  end

  def player_params
    params.require(:player).permit(:name, :jersey_number, :position, :throwing_hand, :batting_hand, :our_team_id, :status, :departure_reason, :birthday, :join_background)
  end
  
  def dummy_stats_params
    params.permit(
      :year,
      batting_stats: [
        :games, :at_bats, :plate_appearances, :hits, :doubles, :triples, :home_runs, :total_bases,
        :rbi, :runs, :stolen_bases, :walks, :strikeouts, :sacrifice_bunts, :sacrifice_flies,
        :batting_average, :on_base_percentage, :slugging_percentage, :ops, :iso, :isod, :fielding_errors
      ],
      pitching_stats: [
        :games_pitched, :appearances, :wins, :losses, :saves, :holds, :outs_pitched, :innings_pitched,
        :hits_allowed, :home_runs_allowed, :strikeouts_pitched, :walks_pitched, :runs_allowed,
        :earned_runs, :whip, :era, :k_bb, :fip, :qs, :hqs, :starts, :complete_games,
        :shutouts, :no_walk_complete_games
      ]
    )
  end
end