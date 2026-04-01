class CreateLessonCompletions < ActiveRecord::Migration[8.0]
  def change
    create_table :lesson_completions do |t|
      t.references :student, null: false, foreign_key: true
      t.references :lesson,  null: false, foreign_key: true

      t.timestamps
    end

    add_index :lesson_completions, [:student_id, :lesson_id], unique: true
  end
end