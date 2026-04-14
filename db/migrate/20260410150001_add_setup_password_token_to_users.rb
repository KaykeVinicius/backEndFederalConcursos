class AddSetupPasswordTokenToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :setup_password_token, :string
    add_column :users, :setup_password_token_expires_at, :datetime
    add_index  :users, :setup_password_token, unique: true, where: "setup_password_token IS NOT NULL"
  end
end
