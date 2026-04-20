class MaterialSerializer < ActiveModel::Serializer
  attributes :id, :title, :material_type, :file_name, :file_url, :file_size,
             :professor_id, :subject_id, :turma_id, :notes, :created_at,
             :course_id, :course_title

  belongs_to :professor, serializer: UserSerializer
  belongs_to :subject,   serializer: SubjectSerializer

  def course_id
    object.turma&.course_id || object.subject&.course_id
  end

  def course_title
    object.turma&.course&.title || object.subject&.course&.title
  end

  def file_url
    if object.file.attached?
      host = Rails.env.development? ? ENV.fetch("RAILS_HOST_POC", "http://localhost:3003") : ENV.fetch("RAILS_HOST", "http://localhost:3001")
      Rails.application.routes.url_helpers.rails_blob_url(object.file, host: host)
    else
      object.file_url
    end
  end

  def file_size
    if object.file.attached?
      size = object.file.byte_size
      size >= 1_048_576 ? "#{(size / 1_048_576.0).round(1)} MB" : "#{(size / 1024.0).round(0).to_i} KB"
    else
      object.file_size
    end
  end
end