class CreateRealTeamStats < ActiveRecord::Migration[8.0]
  def change
    create_table :real_team_stats do |t|
      t.integer :year
      t.string :team_name
      t.float :batting_average
      t.integer :hits
      t.integer :home_runs
      t.integer :rbi
      t.float :on_base_percentage
      t.integer :stolen_bases
      t.float :ops
      t.float :era
      t.integer :wins
      t.integer :strikeouts
      t.integer :holds
      t.integer :saves

      t.timestamps
    end
  end
end
