class EventSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :event_type, :date, :start_time,
             :end_time, :location, :max_participants, :registered_count,
             :status, :is_free, :price, :course_id, :created_at, :is_full,
             :current_lote_price

  has_many :event_lotes, serializer: EventLoteSerializer

  def is_full
    object.full?
  end

  def current_lote_price
    object.current_lote&.price
  end
end