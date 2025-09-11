class AddFieldingPositionToBattingStats < ActiveRecord::Migration[8.0]
  def change
    add_column :batting_stats, :fielding_position, :string
  end
end
