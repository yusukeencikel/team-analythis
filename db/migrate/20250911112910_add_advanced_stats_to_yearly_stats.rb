class AddAdvancedStatsToYearlyStats < ActiveRecord::Migration[8.0]
  def change
    add_column :yearly_stats, :iso, :float
    add_column :yearly_stats, :isod, :float
  end
end
