class CreateCourseSubjects < ActiveRecord::Migration[8.0]
  def up
    create_table :course_subjects do |t|
      t.references :course,  null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.timestamps
    end

    add_index :course_subjects, [:course_id, :subject_id], unique: true

    # Migrar vínculos existentes (subjects que já têm course_id)
    execute <<-SQL
      INSERT INTO course_subjects (course_id, subject_id, created_at, updated_at)
      SELECT course_id, id, NOW(), NOW()
      FROM subjects
      WHERE course_id IS NOT NULL
      ON CONFLICT DO NOTHING
    SQL
  end

  def down
    drop_table :course_subjects
  end
end
