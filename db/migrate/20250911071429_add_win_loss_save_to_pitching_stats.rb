class AddWinLossSaveToPitchingStats < ActiveRecord::Migration[6.1]
  def change
    add_column :pitching_stats, :wins, :integer, default: 0, null: false
    add_column :pitching_stats, :losses, :integer, default: 0, null: false
    add_column :pitching_stats, :saves, :integer, default: 0, null: false
  end
end