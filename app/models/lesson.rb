class Lesson < ApplicationRecord
  belongs_to :topic

  has_many :lesson_pdfs, dependent: :destroy
  has_many :lesson_completions, dependent: :destroy
  has_many :questions, dependent: :destroy

  # youtube_id stores ONLY the embed ID — NEVER the original URL
  validates :title,      presence: true
  validates :youtube_id, presence: true
  validates :position,   presence: true

  scope :ordered,    -> { order(:position) }
  scope :available,  -> { where(available: true) }

  def subject
    topic.subject
  end
end