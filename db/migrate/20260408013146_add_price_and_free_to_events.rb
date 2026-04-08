class AddPriceAndFreeToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :price, :decimal, precision: 10, scale: 2, default: 0
    add_column :events, :is_free, :boolean, default: true, null: false
  end
end
