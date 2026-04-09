class CreateEventSubjects < ActiveRecord::Migration[8.0]
  def change
    create_table :event_subjects do |t|
      t.references :event,   null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.timestamps
    end

    add_index :event_subjects, [:event_id, :subject_id], unique: true
  end
end
