class LessonPdfSerializer < ActiveModel::Serializer
  attributes :id, :name, :file_size, :file_url

  def file_url
    if object.file.attached?
      Rails.application.routes.url_helpers.rails_blob_url(object.file, host: "http://localhost:3001")
    else
      object.file_url
    end
  end
end
