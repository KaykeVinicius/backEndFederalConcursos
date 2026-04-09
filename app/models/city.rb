class City < ApplicationRecord
  has_many :students, dependent: :nullify

  validates :name,  presence: true
  validates :state, presence: true, length: { is: 2 }
  validates :name,  uniqueness: { scope: :state, case_sensitive: false }

  scope :ordered, -> { order(:state, :name) }
end
