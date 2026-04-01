class Career < ApplicationRecord
  has_many :enrollments

  validates :name, presence: true
end