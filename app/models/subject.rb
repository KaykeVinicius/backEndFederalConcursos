class Subject < ApplicationRecord
  belongs_to :course, optional: true
  belongs_to :professor, class_name: "User", optional: true

  has_many :topics, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :materials, dependent: :destroy

  validates :name, presence: true

  scope :ordered, -> { order(:position) }
end