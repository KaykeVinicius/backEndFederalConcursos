class EventRegistrationSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :ticket_token, :attended, :attended_at, :created_at, :lote_name, :lote_price

  belongs_to :student, serializer: StudentSerializer
  belongs_to :event

  def lote_name
    object.event_lote&.name
  end

  def lote_price
    object.event_lote&.price
  end
end
