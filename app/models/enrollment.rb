class Enrollment < ApplicationRecord
  enum :status,          { active: 0, canceled: 1, expired: 2 }
  enum :enrollment_type, { presencial: 0, online: 1, hibrido: 2 }

  belongs_to :student
  belongs_to :course
  belongs_to :turma,  optional: true
  belongs_to :career, optional: true

  has_one :contract

  validates :started_at, presence: true

  after_create  :check_turma_capacity
  after_destroy :check_turma_capacity

  def total_paid
    total_paid_cents.to_f / 100
  end

  def total_paid=(val)
    self.total_paid_cents = (val.to_f * 100).round
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[status enrollment_type payment_method started_at expires_at created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[student course turma career]
  end

  private

  def check_turma_capacity
    turma&.auto_close_if_full!
  end
end