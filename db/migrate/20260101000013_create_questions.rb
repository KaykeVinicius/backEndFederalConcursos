class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.references :student,   null: false, foreign_key: true
      t.references :professor, null: false, foreign_key: { to_table: :users }
      t.references :lesson,    null: false, foreign_key: true
      t.references :subject,   null: false, foreign_key: true
      t.text    :text,         null: false
      t.string  :video_moment
      t.integer :status,       null: false, default: 0
      t.text    :answer
      t.datetime :answered_at

      t.timestamps
    end
  end
end