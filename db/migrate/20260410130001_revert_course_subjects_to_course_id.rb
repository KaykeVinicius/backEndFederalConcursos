class RevertCourseSubjectsToCourseId < ActiveRecord::Migration[8.0]
  def up
    # Remove a tabela de junção many-to-many
    drop_table :course_subjects

    # Garante que a coluna course_id existe e é nullable em subjects
    unless column_exists?(:subjects, :course_id)
      add_reference :subjects, :course, null: true, foreign_key: true
    else
      change_column_null :subjects, :course_id, true
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
