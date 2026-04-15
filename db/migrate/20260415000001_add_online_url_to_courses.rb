class AddOnlineUrlToCourses < ActiveRecord::Migration[7.1]
  def change
    add_column :courses, :online_url, :string
  end
end
