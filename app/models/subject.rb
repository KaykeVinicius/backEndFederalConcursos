class Subject < ApplicationRecord
  belongs_to :course,    optional: true
  belongs_to :professor, class_name: "User", optional: true

  has_many :topics,    dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :materials, dependent: :destroy

  validates :name, presence: true

  scope :ordered, -> { order(:position, :name) }

  def self.ransackable_attributes(auth_object = nil)
    %w[name created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[course professor]
  end
end
