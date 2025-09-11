class AddDetailsToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :birthday, :date
    add_column :players, :join_background, :text
  end
end
