class CreateSubjects < ActiveRecord::Migration[8.0]
  def change
    create_table :subjects do |t|
      t.references :course,    null: false, foreign_key: true
      t.references :professor, null: true,  foreign_key: { to_table: :users }
      t.string  :name,         null: false
      t.text    :description
      t.integer :position,     null: false, default: 0

      t.timestamps
    end
  end
end