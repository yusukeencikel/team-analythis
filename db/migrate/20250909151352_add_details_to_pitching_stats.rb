class AddDetailsToPitchingStats < ActiveRecord::Migration[7.0]
  def change
    add_column :pitching_stats, :pitching_order, :integer
    add_column :pitching_stats, :complete_game, :boolean, default: false, null: false
    add_column :pitching_stats, :shutout, :boolean, default: false, null: false
    # resultカラムをより柔軟な名前に変更 (勝、敗、H、Sなどを保存)
    rename_column :pitching_stats, :result, :pitcher_result
  end
end