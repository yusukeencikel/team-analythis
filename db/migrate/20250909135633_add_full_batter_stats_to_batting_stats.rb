class AddFullBatterStatsToBattingStats < ActiveRecord::Migration[7.0]
  def change
    # 打順と出場区分
    add_column :batting_stats, :batting_order, :integer
    add_column :batting_stats, :participation_type, :string

    # 新しい成績項目のみを追加
    add_column :batting_stats, :doubles, :integer, default: 0
    add_column :batting_stats, :triples, :integer, default: 0
    add_column :batting_stats, :runs, :integer, default: 0
    # 'strikeouts' は既に存在している可能性が高いため、この行をコメントアウトまたは削除
    # add_column :batting_stats, :strikeouts, :integer, default: 0
    add_column :batting_stats, :walks, :integer, default: 0
    add_column :batting_stats, :sacrifice_bunts, :integer, default: 0
    add_column :batting_stats, :sacrifice_flies, :integer, default: 0
    add_column :batting_stats, :double_plays, :integer, default: 0
    add_column :batting_stats, :fielding_errors, :integer, default: 0

    # 念のため、既に存在しないか確認してから追加する、より安全な書き方
    # unless column_exists?(:batting_stats, :strikeouts)
    #   add_column :batting_stats, :strikeouts, :integer, default: 0
    # end
  end
end