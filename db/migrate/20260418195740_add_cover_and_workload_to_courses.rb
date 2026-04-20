class AddCoverAndWorkloadToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :workload_hours, :integer
  end
end
