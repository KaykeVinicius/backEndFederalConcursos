class CourseSubject < ApplicationRecord
  belongs_to :course
  belongs_to :subject

  validates :subject_id, uniqueness: { scope: :course_id }
end
