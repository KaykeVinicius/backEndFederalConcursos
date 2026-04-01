class CreateTopics < ActiveRecord::Migration[8.0]
  def change
    create_table :topics do |t|
      t.references :subject, null: false, foreign_key: true
      t.string  :title,      null: false
      t.integer :position,   null: false, default: 0

      t.timestamps
    end
  end
end