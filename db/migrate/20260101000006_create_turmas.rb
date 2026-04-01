class CreateTurmas < ActiveRecord::Migration[8.0]
  def change
    create_table :turmas do |t|
      t.references :course,    null: false, foreign_key: true
      t.references :professor, null: true,  foreign_key: { to_table: :users }
      t.string  :name,         null: false
      t.string  :shift
      t.date    :start_date,   null: false
      t.date    :end_date,     null: false
      t.string  :schedule
      t.integer :max_students, null: false, default: 40
      t.integer :status,       null: false, default: 0

      t.timestamps
    end
  end
end