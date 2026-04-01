class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :cpf, :role, :commission_percent, :active, :created_at
  # NEVER include password_digest
end