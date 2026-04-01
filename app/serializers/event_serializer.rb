class EventSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :event_type, :date, :start_time,
             :end_time, :location, :max_participants, :registered_count,
             :status, :course_id, :created_at
end