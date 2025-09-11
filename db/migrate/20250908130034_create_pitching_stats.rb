class CreatePitchingStats < ActiveRecord::Migration[8.0]
  def change
    create_table :pitching_stats do |t|
      t.references :player, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true
      t.string :result
      t.float :innings_pitched
      t.integer :hits_allowed
      t.integer :strikeouts
      t.integer :walks_and_hbp
      t.integer :earned_runs
      t.integer :bases_on_balls

      t.timestamps
    end
  end
end
