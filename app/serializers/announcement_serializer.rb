class AnnouncementSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :category, :audience, :pinned, :active, :expires_at, :created_at

  belongs_to :author, serializer: UserSerializer
end
