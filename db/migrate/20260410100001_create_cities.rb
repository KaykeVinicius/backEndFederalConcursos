class CreateCities < ActiveRecord::Migration[8.0]
  def change
    create_table :cities do |t|
      t.string :name,       null: false
      t.string :state,      null: false, limit: 2  # UF
      t.string :ibge_code

      t.timestamps
    end

    add_index :cities, [:name, :state], unique: true
    add_index :cities, :ibge_code, unique: true, where: "ibge_code IS NOT NULL"
  end
end
