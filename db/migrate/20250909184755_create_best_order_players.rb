class CreateBestOrderPlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :best_order_players do |t|
      t.references :best_order, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.integer :batting_order
      t.string :fielding_position

      t.timestamps
    end
  end
end
