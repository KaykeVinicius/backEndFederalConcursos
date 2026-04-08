class CreateEventRegistrations < ActiveRecord::Migration[8.0]
  def change
    create_table :event_registrations do |t|
      t.references :event, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.string :ticket_token
      t.boolean :attended
      t.datetime :attended_at

      t.timestamps
    end
    add_index :event_registrations, :ticket_token, unique: true
  end
end
