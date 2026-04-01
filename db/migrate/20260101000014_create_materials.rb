class CreateMaterials < ActiveRecord::Migration[8.0]
  def change
    create_table :materials do |t|
      t.references :professor, null: false, foreign_key: { to_table: :users }
      t.references :subject,   null: true,  foreign_key: true
      t.references :turma,     null: true,  foreign_key: true
      t.string  :title,        null: false
      t.integer :material_type, null: false, default: 0
      t.string  :file_name
      t.string  :file_url
      t.string  :file_size

      t.timestamps
    end
  end
end