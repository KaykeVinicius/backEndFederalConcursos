class LessonPdfSerializer < ActiveModel::Serializer
  attributes :id, :name, :file_size, :file_url
end