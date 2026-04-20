class LessonPdfSerializer < ActiveModel::Serializer
  attributes :id, :name, :file_size, :file_url

  def file_url
    if object.file.attached?
      host = Rails.env.development? ? ENV.fetch("RAILS_HOST_POC", "http://localhost:3003") : ENV.fetch("RAILS_HOST", "http://localhost:3001")
      Rails.application.routes.url_helpers.rails_blob_url(object.file, host: host)
    else
      object.file_url
    end
  end
end
