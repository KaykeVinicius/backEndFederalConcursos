class LessonPdf < ApplicationRecord
  belongs_to :lesson

  validates :name, presence: true
end