class AddHandednessToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :throwing_hand, :string
    add_column :players, :batting_hand, :string
  end
end
