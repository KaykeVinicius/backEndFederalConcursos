class CreateAccessLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :access_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string  :ip_address
      t.string  :user_agent
      t.string  :device        # "Mobile" | "Desktop" | "Tablet"
      t.string  :browser
      t.string  :action,       null: false, default: "login"
      t.boolean :success,      null: false, default: true

      t.timestamps
    end

    add_index :access_logs, :created_at
  end
end
