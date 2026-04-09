class Student < ApplicationRecord
  belongs_to :user, optional: true

  has_many :enrollments
  has_many :courses,             through: :enrollments
  has_many :questions
  has_many :lesson_completions
  has_many :completed_lessons,   through: :lesson_completions, source: :lesson
  has_many :event_registrations

  validates :name,  presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :cpf,   presence: true, uniqueness: true

  def enrolled_count_for_course(course_id)
    enrollments.where(course_id: course_id, status: :active).count
  end
end