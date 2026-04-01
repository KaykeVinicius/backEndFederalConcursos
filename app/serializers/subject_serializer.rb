class SubjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :position, :course_id, :professor_id, :created_at

  belongs_to :professor, serializer: UserSerializer
end