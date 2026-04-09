class EventLote < ApplicationRecord
  belongs_to :event
  has_many :event_registrations, foreign_key: :event_lote_id, dependent: :nullify

  validates :name,     presence: true
  validates :price,    presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :position, presence: true

  def sold_count
    event_registrations.count
  end

  def available?
    sold_count < quantity
  end

  def sold_out?
    !available?
  end
end
