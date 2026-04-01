class MaterialSerializer < ActiveModel::Serializer
  attributes :id, :title, :material_type, :file_name, :file_url, :file_size,
             :professor_id, :subject_id, :turma_id, :created_at

  belongs_to :professor, serializer: UserSerializer
  belongs_to :subject,   serializer: SubjectSerializer
end