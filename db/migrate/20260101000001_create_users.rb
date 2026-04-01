class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string  :name,               null: false
      t.string  :email,              null: false
      t.string  :password_digest,    null: false
      t.string  :cpf,                null: false
      t.integer :role,               null: false, default: 0
      t.decimal :commission_percent, precision: 5, scale: 2
      t.boolean :active,             null: false, default: true

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :cpf,   unique: true
  end
end