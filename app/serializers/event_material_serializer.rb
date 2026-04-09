class EventMaterialSerializer < ActiveModel::Serializer
  attributes :id, :title, :file_size, :file_url, :expires_at,
             :subject_id, :subject_name, :professor_id, :professor_name,
             :event_id

  def file_url
    if object.file.attached?
      Rails.application.routes.url_helpers.rails_blob_url(object.file, host: ENV.fetch("APP_HOST", "http://localhost:3001"))
    end
  end

  def subject_name
    object.subject&.name
  end

  def professor_name
    object.professor&.name
  end
end
