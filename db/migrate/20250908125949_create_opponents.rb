class CreateOpponents < ActiveRecord::Migration[8.0]
  def change
    create_table :opponents do |t|
      t.string :name
      t.string :home_stadium

      t.timestamps
    end
  end
end
