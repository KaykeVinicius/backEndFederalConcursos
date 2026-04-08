class AddInstagramToStudents < ActiveRecord::Migration[8.0]
  def change
    add_column :students, :instagram, :string
  end
end
