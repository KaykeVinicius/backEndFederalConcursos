class TurmaClassDaySerializer < ActiveModel::Serializer
  attributes :id, :turma_id, :subject_id, :date, :title, :description, :created_at

  attribute :subject_name do
    object.subject&.name
  end

  attribute :professor_name do
    object.subject&.professor&.name
  end

  attribute :professor_id do
    object.subject&.professor_id
  end
end
