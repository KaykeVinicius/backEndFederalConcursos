class CreateEventLotes < ActiveRecord::Migration[8.0]
  def change
    create_table :event_lotes do |t|
      t.references :event, null: false, foreign_key: true
      t.string  :name,     null: false
      t.decimal :price,    null: false, precision: 10, scale: 2
      t.integer :quantity, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end
  end
end
