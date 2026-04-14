class Contract < ApplicationRecord
  enum :status, { pending: 0, signed: 1, expired: 2 }

  belongs_to :enrollment
  belongs_to :student
  belongs_to :course

  validates :version, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[status version signed_at created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[student course enrollment]
  end
end