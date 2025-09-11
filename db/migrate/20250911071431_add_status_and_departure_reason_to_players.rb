class AddStatusAndDepartureReasonToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :status, :string, default: 'active', null: false
    add_column :players, :departure_reason, :string
  end
end