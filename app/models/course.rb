class Course < ApplicationRecord
  enum :status, { draft: 0, published: 1 }
  enum :access_type, { interno: 0, externo: 1, ambos: 2 }

  belongs_to :career, optional: true

  has_many :subjects
  has_many :turmas
  has_many :enrollments
  has_many :students,  through: :enrollments
  has_many :contracts
  has_many :events

  validates :title, presence: true

  def price
    price_cents.to_f / 100
  end

  def price=(val)
    self.price_cents = (val.to_f * 100).round
  end
end