class AddCareerIdToCourses < ActiveRecord::Migration[8.0]
  def change
    add_reference :courses, :career, null: true, foreign_key: true
  end
end
