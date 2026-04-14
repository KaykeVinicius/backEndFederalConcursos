class Announcement < ApplicationRecord
  enum :category, { geral: 0, urgente: 1, evento: 2, financeiro: 3, pedagogico: 4 }
  enum :audience, { todos: 0, alunos: 1, professores: 2, equipe: 3 }

  belongs_to :author, class_name: "User"

  validates :title, presence: true, length: { maximum: 200 }
  validates :body,  presence: true, length: { maximum: 5000 }

  scope :active,   -> { where(active: true).where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :pinned_first, -> { order(pinned: :desc, created_at: :desc) }
  scope :for_audience, ->(role) {
    case role.to_s
    when "aluno"
      where(audience: [:todos, :alunos])
    when "professor"
      where(audience: [:todos, :professores])
    when "ceo", "diretor", "equipe_pedagogica", "assistente_comercial"
      where(audience: [:todos, :equipe])
    else
      where(audience: :todos)
    end
  }

  def self.ransackable_attributes(auth_object = nil)
    %w[title body category audience pinned active created_at expires_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[author]
  end
end
