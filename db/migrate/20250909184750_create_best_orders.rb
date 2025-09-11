class CreateBestOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :best_orders do |t|
      t.string :name

      t.timestamps
    end
  end
end
