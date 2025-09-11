namespace :stats do
  desc "Populates the yearly_stats table with data from existing batting and pitching stats."
  task populate_yearly_stats: :environment do
    puts "Starting to populate yearly stats..."

    puts "Deleting all existing YearlyStat records to ensure a clean slate..."
    YearlyStat.delete_all
    puts "Done."

    Player.find_each do |player|
      puts "Processing player: #{player.name} (ID: #{player.id})"

      # Get all years for which the player has stats
      batting_years = player.batting_stats.joins(:game).distinct.pluck(Arel.sql("EXTRACT(YEAR FROM games.game_date)::integer"))
      pitching_years = player.pitching_stats.joins(:game).distinct.pluck(Arel.sql("EXTRACT(YEAR FROM games.game_date)::integer"))
      all_years = (batting_years + pitching_years).uniq.sort

      all_years.each do |year|
        puts "  - Processing year: #{year}"
        if batting_years.include?(year)
          puts "    -> Updating batting stats..."
          YearlyStatUpdater.update_batting_stats(player, year)
        end
        if pitching_years.include?(year)
          puts "    -> Updating pitching stats..."
          YearlyStatUpdater.update_pitching_stats(player, year)
        end
      end
    end

    puts "Finished populating yearly stats."
  end
end
