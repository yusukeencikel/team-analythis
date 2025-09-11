class AddHitsAndErrorsToGames < ActiveRecord::Migration[8.0]
  def change
    # ▼▼▼【ここから修正】▼▼▼
    # 各カラムを追加する前に、存在しない場合のみ実行するように安全装置を追加
    unless column_exists?(:games, :our_hits)
      add_column :games, :our_hits, :integer
    end
    unless column_exists?(:games, :opponent_hits)
      add_column :games, :opponent_hits, :integer
    end
    unless column_exists?(:games, :our_errors)
      add_column :games, :our_errors, :integer
    end
    unless column_exists?(:games, :opponent_errors)
      add_column :games, :opponent_errors, :integer
    end
    # ▲▲▲【ここまで修正】▲▲▲
  end
end
