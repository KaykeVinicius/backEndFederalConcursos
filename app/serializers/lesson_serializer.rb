class LessonSerializer < ActiveModel::Serializer
  attributes :id, :title, :duration, :youtube_id, :position, :available, :topic_id

  has_many :lesson_pdfs, serializer: LessonPdfSerializer
  # NOTE: youtube_id is the embed ID only — original URL is NEVER returned
end