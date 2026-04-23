class UserType < ApplicationRecord
  VALID_SLUGS = %w[ceo assistente_comercial equipe_pedagogica professor aluno diretor].freeze

  has_many :users, dependent: :nullify

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, inclusion: { in: VALID_SLUGS }

  scope :active,  -> { where(active: true) }
  scope :ordered, -> { order(:position) }
end
