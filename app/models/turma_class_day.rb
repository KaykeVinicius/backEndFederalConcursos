class TurmaClassDay < ApplicationRecord
  belongs_to :turma
  belongs_to :subject

  validates :date, presence: true
  validates :subject_id, uniqueness: { scope: [:turma_id, :date], message: "já tem aula nesta data para esta matéria" }

  scope :ordered, -> { order(date: :asc) }
end
