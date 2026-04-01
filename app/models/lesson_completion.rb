class LessonCompletion < ApplicationRecord
  belongs_to :student
  belongs_to :lesson

  validates :student_id, uniqueness: { scope: :lesson_id }
end