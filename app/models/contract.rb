class Contract < ApplicationRecord
  enum :status, { pending: 0, signed: 1, expired: 2 }

  belongs_to :enrollment
  belongs_to :student
  belongs_to :course

  validates :version, presence: true
end