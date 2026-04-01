class CreateLessons < ActiveRecord::Migration[8.0]
  def change
    create_table :lessons do |t|
      t.references :topic,      null: false, foreign_key: true
      t.string  :title,         null: false
      t.string  :duration
      # IMPORTANT: youtube_id stores only the video embed ID, NOT the full URL
      # The original YouTube URL is NEVER exposed to students
      t.string  :youtube_id,    null: false
      t.integer :position,      null: false, default: 0
      t.boolean :available,     null: false, default: true

      t.timestamps
    end
  end
end