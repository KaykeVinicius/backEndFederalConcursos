class CreateProfessorSubjects < ActiveRecord::Migration[7.1]
  def up
    create_table :professor_subjects do |t|
      t.references :professor, null: false, foreign_key: { to_table: :users }
      t.references :subject,   null: false, foreign_key: true
      t.timestamps
    end
    add_index :professor_subjects, [:professor_id, :subject_id], unique: true

    # Migrate existing single professor_id into the join table
    execute <<~SQL
      INSERT INTO professor_subjects (professor_id, subject_id, created_at, updated_at)
      SELECT professor_id, id, NOW(), NOW()
      FROM subjects
      WHERE professor_id IS NOT NULL
      ON CONFLICT DO NOTHING
    SQL

    remove_column :subjects, :professor_id, :bigint
  end

  def down
    add_column :subjects, :professor_id, :bigint
    add_index  :subjects, :professor_id

    execute <<~SQL
      UPDATE subjects s
      SET professor_id = (
        SELECT professor_id FROM professor_subjects
        WHERE subject_id = s.id
        ORDER BY created_at ASC
        LIMIT 1
      )
    SQL

    drop_table :professor_subjects
  end
end
