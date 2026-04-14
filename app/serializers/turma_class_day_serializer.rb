class TurmaClassDaySerializer < ActiveModel::Serializer
  attributes :id, :turma_id, :subject_id, :date, :title, :description, :created_at

  attribute :start_time do
    object.start_time&.strftime("%H:%M")
  end

  attribute :end_time do
    object.end_time&.strftime("%H:%M")
  end

  attribute :subject_name do
    object.subject&.name
  end

  # Professor específico da aula ou fallback para o professor da turma
  attribute :professor_id do
    object.effective_professor&.id
  end

  attribute :professor_name do
    object.effective_professor&.name
  end
end
