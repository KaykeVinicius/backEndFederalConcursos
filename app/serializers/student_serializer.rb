class StudentSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :whatsapp, :cpf, :instagram,
             :street, :address_number, :address_complement, :neighborhood, :cep,
             :internal, :active, :situacao, :created_at,
             :city_id

  belongs_to :user, serializer: UserSerializer

  attribute :city do
    c = object.city
    c ? { id: c.id, name: c.name, state: c.state } : nil
  end
end
