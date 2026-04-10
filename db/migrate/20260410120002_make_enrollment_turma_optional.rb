class MakeEnrollmentTurmaOptional < ActiveRecord::Migration[8.0]
  def change
    change_column_null :enrollments, :turma_id, true
  end
end
