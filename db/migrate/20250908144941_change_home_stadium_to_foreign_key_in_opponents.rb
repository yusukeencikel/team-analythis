class ChangeHomeStadiumToForeignKeyInOpponents < ActiveRecord::Migration[7.0]
  def change
    # 既存のテキストベースのカラムを削除
    remove_column :opponents, :home_stadium, :string
    # stadiumsテーブルを参照する新しいカラムを追加
    add_reference :opponents, :stadium, null: true, foreign_key: true
  end
end
