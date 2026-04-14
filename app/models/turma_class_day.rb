class TurmaClassDay < ApplicationRecord
  belongs_to :turma
  belongs_to :subject
  belongs_to :professor, class_name: "User", optional: true

  validates :date, presence: true
  validates :subject_id, uniqueness: { scope: [:turma_id, :date], message: "já tem aula nesta data para esta matéria" }

  scope :ordered, -> { order(date: :asc) }

  # Retorna o professor responsável: o específico da aula ou o professor da turma
  def effective_professor
    professor || turma&.professor
  end
end
