class CreateBattingStats < ActiveRecord::Migration[8.0]
  def change
    create_table :batting_stats do |t|
      t.references :player, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true
      t.integer :plate_appearances
      t.integer :at_bats
      t.integer :hits
      t.integer :home_runs
      t.integer :rbi
      t.integer :stolen_bases
      t.integer :strikeouts
      t.integer :walks_and_hbp
      t.integer :sacrifices

      t.timestamps
    end
  end
end
