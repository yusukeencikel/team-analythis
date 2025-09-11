class AddStatsToYearlyStats < ActiveRecord::Migration[7.1]
  def change
    # Add stats_type column if it doesn't exist
    unless column_exists?(:yearly_stats, :stats_type)
      add_column :yearly_stats, :stats_type, :string, null: false
    end

    # Add missing batting stats
    unless column_exists?(:yearly_stats, :double_plays)
      add_column :yearly_stats, :double_plays, :integer, default: 0, null: false
    end
    unless column_exists?(:yearly_stats, :fielding_errors)
      add_column :yearly_stats, :fielding_errors, :integer, default: 0, null: false
    end

    # Add missing pitching stats
    unless column_exists?(:yearly_stats, :starts)
      add_column :yearly_stats, :starts, :integer, default: 0, null: false
    end
    unless column_exists?(:yearly_stats, :complete_games)
      add_column :yearly_stats, :complete_games, :integer, default: 0, null: false
    end
    unless column_exists?(:yearly_stats, :shutouts)
      add_column :yearly_stats, :shutouts, :integer, default: 0, null: false
    end
    unless column_exists?(:yearly_stats, :no_walk_complete_games)
      add_column :yearly_stats, :no_walk_complete_games, :integer, default: 0, null: false
    end
    unless column_exists?(:yearly_stats, :outs_pitched)
      add_column :yearly_stats, :outs_pitched, :integer, default: 0, null: false
    end
    unless column_exists?(:yearly_stats, :wild_pitches)
      add_column :yearly_stats, :wild_pitches, :integer, default: 0, null: false
    end
    unless column_exists?(:yearly_stats, :qs)
      add_column :yearly_stats, :qs, :integer, default: 0, null: false
    end
    unless column_exists?(:yearly_stats, :hqs)
      add_column :yearly_stats, :hqs, :integer, default: 0, null: false
    end

    # Add missing calculated pitching stats
    unless column_exists?(:yearly_stats, :k_per_nine)
      add_column :yearly_stats, :k_per_nine, :float, default: 0.0, null: false
    end
    unless column_exists?(:yearly_stats, :k_bb)
      add_column :yearly_stats, :k_bb, :float, default: 0.0, null: false
    end
    unless column_exists?(:yearly_stats, :fip)
      add_column :yearly_stats, :fip, :float, default: 0.0, null: false
    end

    # Rename walks_pitched to walks_allowed for consistency if it exists
    if column_exists?(:yearly_stats, :walks_pitched) && !column_exists?(:yearly_stats, :walks_allowed)
      rename_column :yearly_stats, :walks_pitched, :walks_allowed
    end
    
    # Add index on player, year, and stats_type for uniqueness and performance
    unless index_exists?(:yearly_stats, [:player_id, :year, :stats_type])
      add_index :yearly_stats, [:player_id, :year, :stats_type], unique: true
    end
  end
end
