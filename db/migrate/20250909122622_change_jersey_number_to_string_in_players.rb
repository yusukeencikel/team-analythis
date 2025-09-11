class ChangeJerseyNumberToStringInPlayers < ActiveRecord::Migration[7.0]
  def change
    change_column :players, :jersey_number, :string
  end
end
