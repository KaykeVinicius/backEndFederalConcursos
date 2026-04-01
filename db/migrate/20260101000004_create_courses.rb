class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string  :title,            null: false
      t.text    :description
      t.integer :price_cents,      null: false, default: 0
      t.integer :status,           null: false, default: 0
      t.integer :access_type,      null: false, default: 0
      t.integer :duration_in_days
      t.date    :start_date
      t.date    :end_date

      t.timestamps
    end
  end
end