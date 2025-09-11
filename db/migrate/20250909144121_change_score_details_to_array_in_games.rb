class ChangeScoreDetailsToArrayInGames < ActiveRecord::Migration[7.0]
  def change
    # 既存のstringカラムを一度削除
    remove_column :games, :our_score_details, :string
    remove_column :games, :opponent_score_details, :string

    # 新しくstringの配列型カラムとして追加
    add_column :games, :our_score_details, :string, array: true, default: []
    add_column :games, :opponent_score_details, :string, array: true, default: []
  end
end
