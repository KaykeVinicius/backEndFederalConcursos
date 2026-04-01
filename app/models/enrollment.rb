class Enrollment < ApplicationRecord
  enum :status,          { active: 0, canceled: 1, expired: 2 }
  enum :enrollment_type, { interno: 0, externo: 1 }

  belongs_to :student
  belongs_to :course
  belongs_to :turma
  belongs_to :career, optional: true

  has_one :contract

  validates :started_at, presence: true

  def total_paid
    total_paid_cents.to_f / 100
  end

  def total_paid=(val)
    self.total_paid_cents = (val.to_f * 100).round
  end
end