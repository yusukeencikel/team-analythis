class AddQualityStartRatesToYearlyStats < ActiveRecord::Migration[8.0]
  def change
    add_column :yearly_stats, :qs_rate, :float
    add_column :yearly_stats, :hqs_rate, :float
  end
end
