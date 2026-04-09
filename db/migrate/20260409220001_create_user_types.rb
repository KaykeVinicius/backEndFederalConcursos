class CreateUserTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :user_types do |t|
      t.string  :name,        null: false
      t.string  :slug,        null: false  # corresponde ao enum role (ex: "ceo", "professor")
      t.string  :description
      t.boolean :active,      default: true, null: false
      t.integer :position,    default: 0,   null: false
      t.timestamps
    end

    add_index :user_types, :slug, unique: true

    add_reference :users, :user_type, foreign_key: true, null: true
  end
end
