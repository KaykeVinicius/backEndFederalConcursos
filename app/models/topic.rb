class Topic < ApplicationRecord
  belongs_to :subject

  has_many :lessons, dependent: :destroy

  validates :title,    presence: true
  validates :position, presence: true

  scope :ordered, -> { order(:position) }
end