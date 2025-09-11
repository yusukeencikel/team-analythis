class AddFullStatsToRealPlayerStats < ActiveRecord::Migration[7.0]
  def change
    # 投手成績
    add_column :real_player_stats, :appearances, :integer
    add_column :real_player_stats, :starts, :integer
    add_column :real_player_stats, :complete_games, :integer
    add_column :real_player_stats, :shutouts, :integer
    add_column :real_player_stats, :no_walks, :integer
    add_column :real_player_stats, :losses, :integer
    add_column :real_player_stats, :saves, :integer
    add_column :real_player_stats, :holds, :integer
    add_column :real_player_stats, :winning_percentage, :float
    add_column :real_player_stats, :batters_faced, :integer
    add_column :real_player_stats, :innings_pitched, :float
    add_column :real_player_stats, :hits_allowed, :integer
    add_column :real_player_stats, :home_runs_allowed, :integer
    add_column :real_player_stats, :walks, :integer
    add_column :real_player_stats, :wild_pitches, :integer
    add_column :real_player_stats, :runs_allowed, :integer
    add_column :real_player_stats, :earned_runs, :integer
    add_column :real_player_stats, :whip, :float

    # 野手成績
    add_column :real_player_stats, :games, :integer
    add_column :real_player_stats, :plate_appearances, :integer
    add_column :real_player_stats, :at_bats, :integer
    add_column :real_player_stats, :runs, :integer
    add_column :real_player_stats, :hits, :integer
    add_column :real_player_stats, :doubles, :integer
    add_column :real_player_stats, :triples, :integer
    add_column :real_player_stats, :stolen_bases, :integer
    add_column :real_player_stats, :sacrifice_bunts, :integer
    add_column :real_player_stats, :sacrifice_flies, :integer
    add_column :real_player_stats, :batter_walks, :integer
    add_column :real_player_stats, :batter_strikeouts, :integer
    add_column :real_player_stats, :double_plays, :integer
    add_column :real_player_stats, :on_base_percentage, :float
    add_column :real_player_stats, :slugging_percentage, :float
    add_column :real_player_stats, :ops, :float
  end
end