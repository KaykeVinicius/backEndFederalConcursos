class LessonPdf < ApplicationRecord
  belongs_to :lesson
  has_one_attached :file

  validates :name, presence: true
end