class MaterialSerializer < ActiveModel::Serializer
  attributes :id, :title, :material_type, :file_name, :file_url, :file_size,
             :professor_id, :subject_id, :turma_id, :notes, :created_at

  belongs_to :professor, serializer: UserSerializer
  belongs_to :subject,   serializer: SubjectSerializer

  def file_url
    if object.file.attached?
      Rails.application.routes.url_helpers.rails_blob_url(object.file, host: "http://localhost:3001")
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