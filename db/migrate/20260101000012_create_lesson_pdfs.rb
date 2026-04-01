class CreateLessonPdfs < ActiveRecord::Migration[8.0]
  def change
    create_table :lesson_pdfs do |t|
      t.references :lesson, null: false, foreign_key: true
      t.string :name,       null: false
      t.string :file_size
      t.string :file_url

      t.timestamps
    end
  end
end