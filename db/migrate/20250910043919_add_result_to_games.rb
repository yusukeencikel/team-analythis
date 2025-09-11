class AddResultToGames < ActiveRecord::Migration[7.1]
  def change
    # gamesテーブルにresultカラムが存在しない場合のみ、カラムを追加する
    unless column_exists?(:games, :result)
      add_column :games, :result, :string
    end
  end
end
