class AddDetailedStatsToPitchingStats < ActiveRecord::Migration[7.0]
  def change
    # 新しいカラムを追加 (未入力は0とする)
    add_column :pitching_stats, :batters_faced, :integer, default: 0, null: false
    add_column :pitching_stats, :pitches_thrown, :integer, default: 0, null: false
    add_column :pitching_stats, :walks, :integer, default: 0, null: false
    add_column :pitching_stats, :runs_allowed, :integer, default: 0, null: false
    add_column :pitching_stats, :wild_pitches, :integer, default: 0, null: false
    add_column :pitching_stats, :home_runs_allowed, :integer, default: 0, null: false

    # 不要になったカラムを削除
    remove_column :pitching_stats, :complete_game, :boolean
    remove_column :pitching_stats, :shutout, :boolean

    # 既存のカラム名を、より分かりやすい名前に変更
    rename_column :pitching_stats, :bases_on_balls, :hit_by_pitches
  end
end