class EnsureAllBattingStatColumnsExist < ActiveRecord::Migration[7.0]
  def change
    # 基本情報
    add_column :batting_stats, :batting_order, :integer unless column_exists?(:batting_stats, :batting_order)
    add_column :batting_stats, :participation_type, :string unless column_exists?(:batting_stats, :participation_type)
    add_column :batting_stats, :fielding_position, :string unless column_exists?(:batting_stats, :fielding_position)

    # 成績項目 (default: 0 を徹底)
    add_column :batting_stats, :doubles, :integer, default: 0, null: false unless column_exists?(:batting_stats, :doubles)
    add_column :batting_stats, :triples, :integer, default: 0, null: false unless column_exists?(:batting_stats, :triples)
    add_column :batting_stats, :runs, :integer, default: 0, null: false unless column_exists?(:batting_stats, :runs)
    add_column :batting_stats, :walks, :integer, default: 0, null: false unless column_exists?(:batting_stats, :walks)
    add_column :batting_stats, :sacrifice_bunts, :integer, default: 0, null: false unless column_exists?(:batting_stats, :sacrifice_bunts)
    add_column :batting_stats, :sacrifice_flies, :integer, default: 0, null: false unless column_exists?(:batting_stats, :sacrifice_flies)
    add_column :batting_stats, :double_plays, :integer, default: 0, null: false unless column_exists?(:batting_stats, :double_plays)
    add_column :batting_stats, :fielding_errors, :integer, default: 0, null: false unless column_exists?(:batting_stats, :fielding_errors)

    # 既存カラムのデフォルト値も0に設定
    change_column_default :batting_stats, :at_bats, from: nil, to: 0
    change_column_default :batting_stats, :hits, from: nil, to: 0
    change_column_default :batting_stats, :home_runs, from: nil, to: 0
    change_column_default :batting_stats, :rbi, from: nil, to: 0
    change_column_default :batting_stats, :strikeouts, from: nil, to: 0
    change_column_default :batting_stats, :stolen_bases, from: nil, to: 0
  end
end