class OurTeam < ApplicationRecord
  belongs_to :stadium, optional: true
  has_one_attached :icon

  def self.yearly_stats
    # Gameテーブルから存在する全ての年度を取得
    years = Game.distinct.pluck(Arel.sql("EXTRACT(YEAR FROM game_date)::integer")).sort.reverse

    years.map do |year|
      games_in_year = Game.where("EXTRACT(YEAR FROM game_date) = ?", year.to_s)
      game_ids_in_year = games_in_year.pluck(:id)

      # 試合結果の集計
      wins = games_in_year.where(result: 'win').count
      losses = games_in_year.where(result: 'lose').count
      draws = games_in_year.where(result: 'draw').count
      total_games = wins + losses + draws

      # チーム打撃成績の集計
      batting_stats = BattingStat.where(game_id: game_ids_in_year)
      total_hits = batting_stats.sum(:hits)
      total_at_bats = batting_stats.sum(:at_bats)
      team_avg = total_at_bats > 0 ? (total_hits.to_f / total_at_bats).round(3) : 0
      team_home_runs = batting_stats.sum(:home_runs)

      # チーム投手成績の集計
      pitching_stats = PitchingStat.where(game_id: game_ids_in_year)
      total_earned_runs = pitching_stats.sum(:earned_runs)
      total_outs_pitched = pitching_stats.sum(:outs_pitched)
      total_innings_pitched = total_outs_pitched.to_f / 3
      team_era = total_innings_pitched > 0 ? ((total_earned_runs.to_f * 9) / total_innings_pitched).round(2) : 0

      {
        year: year,
        total_games: total_games,
        wins: wins,
        losses: losses,
        draws: draws,
        team_avg: team_avg,
        team_home_runs: team_home_runs,
        team_era: team_era
      }
    end
  end
end
