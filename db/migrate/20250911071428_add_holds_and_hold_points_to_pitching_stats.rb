class AddHoldsAndHoldPointsToPitchingStats < ActiveRecord::Migration[6.1]
  def change
    add_column :pitching_stats, :holds, :integer, default: 0, null: false
    add_column :pitching_stats, :hold_points, :integer, default: 0, null: false
  end
end