class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :notifiable_type, :notifiable_id, :read_at, :created_at
end
