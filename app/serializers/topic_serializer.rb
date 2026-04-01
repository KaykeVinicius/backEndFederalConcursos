class TopicSerializer < ActiveModel::Serializer
  attributes :id, :title, :position, :subject_id

  has_many :lessons, serializer: LessonSerializer
end