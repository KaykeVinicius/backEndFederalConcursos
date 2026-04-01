class Question < ApplicationRecord
  enum :status, { pending: 0, answered: 1 }

  belongs_to :student
  belongs_to :professor, class_name: "User"
  belongs_to :lesson
  belongs_to :subject

  validates :text, presence: true

  scope :for_professor, ->(professor_id) { where(professor_id: professor_id) }
  scope :pending_answers, -> { where(status: :pending) }

  def answer!(text)
    update!(answer: text, status: :answered, answered_at: Time.current)
  end
end