class MakeCourseIdOptionalInSubjects < ActiveRecord::Migration[8.0]
  def change
    change_column_null :subjects, :course_id, true
  end
end
