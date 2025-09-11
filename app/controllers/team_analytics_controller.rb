class TeamAnalyticsController < ApplicationController
  def show
    # --- 共通データ準備 ---
    @team_yearly_stats = OurTeam.yearly_stats
    @search_years = Game.distinct.pluck(Arel.sql("EXTRACT(YEAR FROM game_date)::integer")).sort.reverse
    @search_positions = Player.distinct.pluck(:position).compact.sort
    
    # @display_year のデフォルトを最新年に設定
    @display_year = params[:year].presence || @search_years.first
    
    @active_main_tab = params[:main_tab] || 'team'
    @active_sub_tab = params[:sub_tab] || 'stats-list'

    # ソート関連のパラメータ
    sort_column = params[:sort]
    sort_direction = params[:direction]

    if @active_main_tab == 'batting'
      # --- 野手成績用のデータ取得 ---
      players_scope = Player.includes(:yearly_stats)

      if @display_year.present?
        # その年に成績がある選手に絞り込む
        player_ids = BattingStat.joins(:game).where("EXTRACT(YEAR FROM games.game_date) = ?", @display_year).pluck(:player_id).uniq
        players_scope = players_scope.where(id: player_ids)
      end

      if params[:position].present?
        players_scope = players_scope.where(position: params[:position])
      end

      # ソート
      if sort_column.present? && @display_year.present?
        allowed_columns = YearlyStat.column_names + ['name']
        if allowed_columns.include?(sort_column)
          db_sort_direction = sort_direction == 'asc' ? :asc : :desc
          if sort_column == 'name'
            players_scope = players_scope.order("players.name #{db_sort_direction}")
          else
            # ソートのために yearly_stats を JOIN
            players_scope = players_scope.joins(:yearly_stats)
                                       .where(yearly_stats: { year: @display_year, stats_type: 'batting' })
                                       .order(Arel.sql("yearly_stats.#{sort_column} #{db_sort_direction} NULLS LAST"))
          end
        end
      else
        players_scope = players_scope.order(jersey_number: :asc)
      end

      @players = players_scope.to_a

      if params[:qualified] == 'true' && @display_year.present?
        year_for_qualification = @display_year
        @players.select! { |player| player.qualified_for_batting_average?(year_for_qualification) }
      end

      # ランキング
      players_with_stats = @players.map { |p| [p, p.stats_for(@display_year)] }.select { |_, stats| stats.present? }
      @batting_average_ranking = players_with_stats.sort_by { |_, stats| stats.batting_average || 0 }.reverse
      @on_base_percentage_ranking = players_with_stats.sort_by { |_, stats| stats.on_base_percentage || 0 }.reverse
      @slugging_percentage_ranking = players_with_stats.sort_by { |_, stats| stats.slugging_percentage || 0 }.reverse
      @ops_ranking = players_with_stats.sort_by { |_, stats| stats.ops || 0 }.reverse
      @hits_ranking = players_with_stats.sort_by { |_, stats| stats.hits || 0 }.reverse
      @home_run_ranking = players_with_stats.sort_by { |_, stats| stats.home_runs || 0 }.reverse
      @rbi_ranking = players_with_stats.sort_by { |_, stats| stats.rbi || 0 }.reverse
      @stolen_bases_ranking = players_with_stats.sort_by { |_, stats| stats.stolen_bases || 0 }.reverse

    elsif @active_main_tab == 'pitching'
      # --- 投手成績用のデータ取得 ---
      pitchers_scope = Player.includes(:yearly_stats)

      if @display_year.present?
        # その年に成績がある選手に絞り込む
        player_ids = PitchingStat.joins(:game).where("EXTRACT(YEAR FROM games.game_date) = ?", @display_year).pluck(:player_id).uniq
        pitchers_scope = pitchers_scope.where(id: player_ids)
      end

      # ソート
      if sort_column.present? && @display_year.present?
        allowed_columns = YearlyStat.column_names + ['name']
        if allowed_columns.include?(sort_column)
          default_direction = %w[era whip fip].include?(sort_column) ? 'asc' : 'desc'
          db_sort_direction = (sort_direction || default_direction) == 'asc' ? :asc : :desc
          
          if sort_column == 'name'
            pitchers_scope = pitchers_scope.order("players.name #{db_sort_direction}")
          else
            # ソートのために yearly_stats を JOIN
            pitchers_scope = pitchers_scope.joins(:yearly_stats)
                                         .where(yearly_stats: { year: @display_year, stats_type: 'pitching' })
                                         .order(Arel.sql("yearly_stats.#{sort_column} #{db_sort_direction} NULLS LAST"))
          end
        end
      else
        # デフォルトソート (防御率)
        if @display_year.present?
          pitchers_scope = pitchers_scope.joins(:yearly_stats)
                                       .where(yearly_stats: { year: @display_year, stats_type: 'pitching' })
                                       .order(Arel.sql("yearly_stats.era asc NULLS LAST"))
        end
      end
      
      @pitchers = pitchers_scope.to_a

      if params[:qualified] == 'true' && @display_year.present?
        year_for_qualification = @display_year
        @pitchers.select! { |pitcher| pitcher.qualified_for_era?(year_for_qualification) }
      end

      # ランキング
      pitchers_with_stats = @pitchers.map { |p| [p, p.pitching_stats_for(@display_year)] }.select { |_, stats| stats.present? }
      @era_ranking = pitchers_with_stats.sort_by { |_, stats| stats.era || 999 }
      @wins_ranking = pitchers_with_stats.sort_by { |_, stats| stats.wins || 0 }.reverse
      @strikeouts_ranking = pitchers_with_stats.sort_by { |_, stats| stats.strikeouts_pitched || 0 }.reverse
      @saves_ranking = pitchers_with_stats.sort_by { |_, stats| stats.saves || 0 }.reverse
      @holds_ranking = pitchers_with_stats.sort_by { |_, stats| stats.holds || 0 }.reverse
      @whip_ranking = pitchers_with_stats.sort_by { |_, stats| stats.whip || 999 }
    end
  end
end
