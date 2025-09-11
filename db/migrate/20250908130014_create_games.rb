class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.date :game_date
      t.string :day_night
      t.string :home_away
      t.integer :our_score
      t.integer :opponent_score
      t.string :our_score_details
      t.string :opponent_score_details
      # ... (他の行はそのまま)
      t.references :opponent, null: false, foreign_key: true
      t.references :stadium, null: true, foreign_key: true
      t.references :winning_pitcher, null: true, foreign_key: { to_table: :players }
      t.references :losing_pitcher, null: true, foreign_key: { to_table: :players }
      t.references :saving_pitcher, null: true, foreign_key: { to_table: :players }
      # ... (他の行はそのまま)

      t.timestamps
    end
  end
end
