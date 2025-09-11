# app/services/yearly_stat_updater.rb
class YearlyStatUpdater
  class << self
    include StatCalculable

    def update_batting_stats(player, year)
      stats_collection = player.batting_stats.joins(:game).where("EXTRACT(YEAR FROM games.game_date) = ?", year)
      summary = summarize_batting_stats(stats_collection)

      yearly_stat = YearlyStat.find_or_initialize_by(
        player: player,
        year: year,
        stats_type: 'batting'
      )

      if summary.empty?
        yearly_stat.destroy if yearly_stat.persisted?
      else
        yearly_stat.update!(summary)
      end
    end

    def update_pitching_stats(player, year)
      stats_collection = player.pitching_stats.joins(:game).where("EXTRACT(YEAR FROM games.game_date) = ?", year)
      summary = summarize_pitching_stats(stats_collection)

      yearly_stat = YearlyStat.find_or_initialize_by(
        player: player,
        year: year,
        stats_type: 'pitching'
      )
      
      if summary.empty?
        yearly_stat.destroy if yearly_stat.persisted?
      else
        yearly_stat.update!(summary)
      end
    end
  end
end
