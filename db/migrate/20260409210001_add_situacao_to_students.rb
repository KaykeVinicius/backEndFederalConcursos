class AddSituacaoToStudents < ActiveRecord::Migration[8.0]
  def change
    add_column :students, :situacao, :integer, default: 0, null: false
  end
end
