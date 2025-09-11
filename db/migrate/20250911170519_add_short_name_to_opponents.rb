class AddShortNameToOpponents < ActiveRecord::Migration[7.2]
  def change
    add_column :opponents, :short_name, :string
  end
end
