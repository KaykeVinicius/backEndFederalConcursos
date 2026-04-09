class CitySerializer < ActiveModel::Serializer
  attributes :id, :name, :state, :ibge_code
end
