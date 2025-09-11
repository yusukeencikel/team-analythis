class AddDetailsToGames < ActiveRecord::Migration[7.0]
  def change
    # 試合結果 (勝ち/負け/引き分け)
    add_column :games, :result, :string
    # 安打数とエラー数
    add_column :games, :our_hits, :integer
    add_column :games, :opponent_hits, :integer
    add_column :games, :our_errors, :integer
    add_column :games, :opponent_errors, :integer
    # 先攻/後攻
    add_column :games, :first_move, :string
  end
end
