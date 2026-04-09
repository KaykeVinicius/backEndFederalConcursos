class EventLoteSerializer < ActiveModel::Serializer
  attributes :id, :name, :price, :quantity, :position, :sold_count, :available

  def available
    object.available?
  end
end
