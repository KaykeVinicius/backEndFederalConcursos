class UserTypeSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :description, :active, :position, :users_count

  def users_count
    object.users.count
  end
end
