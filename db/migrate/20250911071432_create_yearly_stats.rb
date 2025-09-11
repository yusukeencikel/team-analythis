# db/migrate/xxxxxx_create_yearly_stats.rb
class CreateYearlyStats < ActiveRecord::Migration[7.0]
  def change
    create_table :yearly_stats do |t|
      t.references :player, null: false, foreign_key: true
      t.integer :year, null: false
      t.string :stats_type, null: false # 'pitching' または 'batting'
      
      # 野手用フィールド
      t.integer :games, default: 0
      t.integer :at_bats, default: 0
      t.integer :plate_appearances, default: 0
      t.integer :hits, default: 0
      t.integer :doubles, default: 0
      t.integer :triples, default: 0
      t.integer :home_runs, default: 0
      t.integer :total_bases, default: 0
      t.integer :rbi, default: 0
      t.integer :runs, default: 0
      t.integer :stolen_bases, default: 0
      t.integer :walks, default: 0
      t.integer :strikeouts, default: 0
      t.integer :sacrifice_bunts, default: 0
      t.integer :sacrifice_flies, default: 0
      t.decimal :batting_average, precision: 4, scale: 3
      t.decimal :on_base_percentage, precision: 4, scale: 3
      t.decimal :slugging_percentage, precision: 4, scale: 3
      t.decimal :ops, precision: 4, scale: 3
      t.decimal :iso, precision: 4, scale: 3
      t.decimal :isod, precision: 4, scale: 3
      t.integer :fielding_errors, default: 0
      
      # 投手用フィールド
      t.integer :games_pitched, default: 0
      t.integer :appearances, default: 0
      t.integer :wins, default: 0
      t.integer :losses, default: 0
      t.integer :saves, default: 0
      t.integer :holds, default: 0
      t.integer :outs_pitched, default: 0
      t.integer :innings_pitched, default: 0
      t.integer :hits_allowed, default: 0
      t.integer :home_runs_allowed, default: 0
      t.integer :strikeouts_pitched, default: 0
      t.integer :walks_pitched, default: 0
      t.integer :runs_allowed, default: 0
      t.integer :earned_runs, default: 0
      t.decimal :whip, precision: 4, scale: 2
      t.decimal :era, precision: 4, scale: 2
      t.decimal :k_bb, precision: 4, scale: 2
      t.decimal :fip, precision: 4, scale: 2
      t.integer :qs, default: 0
      t.integer :hqs, default: 0
      t.integer :starts, default: 0
      t.integer :complete_games, default: 0
      t.integer :shutouts, default: 0
      t.integer :no_walk_complete_games, default: 0
      
      t.timestamps
    end
    
    add_index :yearly_stats, [:player_id, :year, :stats_type], unique: true
  end
end