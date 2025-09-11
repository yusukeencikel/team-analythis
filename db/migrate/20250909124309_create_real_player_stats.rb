class CreateRealPlayerStats < ActiveRecord::Migration[8.0]
  def change
    create_table :real_player_stats do |t|
      t.integer :year
      t.string :player_name
      t.string :team_name
      t.float :batting_average
      t.integer :home_runs
      t.integer :rbi
      t.float :era
      t.integer :wins
      t.integer :strikeouts

      t.timestamps
    end
  end
end
