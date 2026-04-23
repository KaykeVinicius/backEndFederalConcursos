class SubjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :position, :course_id, :created_at

  attribute :professors do
    object.professors.map { |p| { id: p.id, name: p.name } }
  end
end
