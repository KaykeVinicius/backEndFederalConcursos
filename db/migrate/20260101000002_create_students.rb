class CreateStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :students do |t|
      t.references :user,     foreign_key: true
      t.string  :name,        null: false
      t.string  :email,       null: false
      t.string  :whatsapp
      t.string  :cpf,         null: false
      t.text    :address
      t.boolean :internal,    null: false, default: true
      t.boolean :active,      null: false, default: true

      t.timestamps
    end

    add_index :students, :email, unique: true
    add_index :students, :cpf,   unique: true
  end
end