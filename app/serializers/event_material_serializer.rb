class EventMaterialSerializer < ActiveModel::Serializer
  attributes :id, :title, :file_size, :file_url, :expires_at,
             :subject_id, :subject_name, :professor_id, :professor_name,
             :event_id

  def file_url
    if object.file.attached?
      host = Rails.env.development? ? ENV.fetch("RAILS_HOST_POC", "http://localhost:3003") : ENV.fetch("RAILS_HOST", "http://localhost:3001")
      Rails.application.routes.url_helpers.rails_blob_url(object.file, host: host)
    end
  end

  def subject_name
    object.subject&.name
  end

  def professor_name
    object.professor&.name
  end
end
