class CreateStadia < ActiveRecord::Migration[8.0]
  def change
    create_table :stadia do |t|
      t.string :name

      t.timestamps
    end
  end
end
