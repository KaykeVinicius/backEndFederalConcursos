class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.references :course,          null: true, foreign_key: true
      t.string  :title,              null: false
      t.text    :description
      t.integer :event_type,         null: false, default: 0
      t.date    :date,               null: false
      t.string  :start_time,         null: false
      t.string  :end_time,           null: false
      t.string  :location
      t.integer :max_participants,   null: false, default: 100
      t.integer :registered_count,   null: false, default: 0
      t.integer :status,             null: false, default: 0

      t.timestamps
    end
  end
end