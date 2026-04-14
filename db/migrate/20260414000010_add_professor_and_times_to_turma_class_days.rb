class AddProfessorAndTimesToTurmaClassDays < ActiveRecord::Migration[8.0]
  def change
    add_reference :turma_class_days, :professor, foreign_key: { to_table: :users }, null: true
    add_column    :turma_class_days, :start_time, :time
    add_column    :turma_class_days, :end_time,   :time
  end
end
