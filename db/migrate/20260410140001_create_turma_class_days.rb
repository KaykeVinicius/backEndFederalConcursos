class CreateTurmaClassDays < ActiveRecord::Migration[8.0]
  def change
    create_table :turma_class_days do |t|
      t.references :turma,   null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.date   :date,    null: false
      t.string :title
      t.text   :description

      t.timestamps
    end

    add_index :turma_class_days, [:turma_id, :date]
  end
end
