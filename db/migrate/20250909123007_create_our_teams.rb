class CreateOurTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :our_teams do |t|
      t.string :name
      t.string :league
      t.references :stadium, null: true, foreign_key: true

      t.timestamps
    end
  end
end
