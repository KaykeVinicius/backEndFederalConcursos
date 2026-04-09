class CreateEventMaterials < ActiveRecord::Migration[8.0]
  def change
    create_table :event_materials do |t|
      t.references :event,   null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.references :professor, null: false, foreign_key: { to_table: :users }
      t.string  :title,      null: false
      t.string  :file_size
      t.datetime :expires_at, null: false
      t.timestamps
    end
  end
end
