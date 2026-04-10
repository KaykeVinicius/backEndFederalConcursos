class Course < ApplicationRecord
  enum :status, { draft: 0, published: 1 }
  enum :access_type, { presencial: 0, online: 1, hibrido: 2 }

  belongs_to :career, optional: true

  has_many :subjects
  has_many :turmas
  has_many :enrollments
  has_many :students,  through: :enrollments
  has_many :contracts
  has_many :events

  validates :title, presence: true

  before_destroy :check_no_active_enrollments

  def price
    price_cents.to_f / 100
  end

  def price=(val)
    self.price_cents = (val.to_f * 100).round
  end

  private

  def check_no_active_enrollments
    if enrollments.active.exists?
      errors.add(:base, "Não é possível excluir um curso com alunos matriculados ativos.")
      throw :abort
    end
  end
end
