class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user,           null: false, foreign_key: true
      t.string     :notifiable_type, null: false  # "Event" | "Course"
      t.integer    :notifiable_id,   null: false
      t.string     :title,           null: false
      t.string     :body
      t.datetime   :read_at
      t.timestamps
    end

    add_index :notifications, [:user_id, :read_at]
    add_index :notifications, [:notifiable_type, :notifiable_id]
  end
end
