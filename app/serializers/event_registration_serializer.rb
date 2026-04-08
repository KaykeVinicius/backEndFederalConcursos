class EventRegistrationSerializer < ActiveModel::Serializer
  attributes :id, :ticket_token, :attended, :attended_at, :created_at

  belongs_to :student, serializer: StudentSerializer
  belongs_to :event
end
