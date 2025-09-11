class AddAllDetailsToBattingStats < ActiveRecord::Migration[7.0]
  def change
    # 以前のマイグレーションで追加した可能性があるため、存在しない場合のみ追加
    unless column_exists?(:batting_stats, :fielding_position)
      add_column :batting_stats, :fielding_position, :string
    end

    # 以前のマイグレーションで追加した可能性があるため、存在しない場合のみ追加
    unless column_exists?(:batting_stats, :batting_order)
      add_column :batting_stats, :batting_order, :integer
    end
    unless column_exists?(:batting_stats, :participation_type)
      add_column :batting_stats, :participation_type, :string
    end

    # 新しい成績項目。未入力の場合は0を自動で入力するように設定
    # 既に存在するカラムは、このファイルでは追加しない
    unless column_exists?(:batting_stats, :doubles)
      add_column :batting_stats, :doubles, :integer, default: 0, null: false
    end
    unless column_exists?(:batting_stats, :triples)
      add_column :batting_stats, :triples, :integer, default: 0, null: false
    end
    unless column_exists?(:batting_stats, :runs)
      add_column :batting_stats, :runs, :integer, default: 0, null: false
    end
    unless column_exists?(:batting_stats, :walks)
      add_column :batting_stats, :walks, :integer, default: 0, null: false
    end
    unless column_exists?(:batting_stats, :sacrifice_bunts)
      add_column :batting_stats, :sacrifice_bunts, :integer, default: 0, null: false
    end
    unless column_exists?(:batting_stats, :sacrifice_flies)
      add_column :batting_stats, :sacrifice_flies, :integer, default: 0, null: false
    end
    unless column_exists?(:batting_stats, :double_plays)
      add_column :batting_stats, :double_plays, :integer, default: 0, null: false
    end
    unless column_exists?(:batting_stats, :fielding_errors)
      add_column :batting_stats, :fielding_errors, :integer, default: 0, null: false
    end
  end
end