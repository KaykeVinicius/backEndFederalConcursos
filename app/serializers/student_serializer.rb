class StudentSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :whatsapp, :cpf, :address, :internal, :active, :created_at

  belongs_to :user, serializer: UserSerializer
end