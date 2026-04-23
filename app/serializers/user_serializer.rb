class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :cpf, :role, :commission_percent, :active, :created_at,
             :user_type_id

  # NEVER include password_digest

  attribute :user_type do
    ut = object.user_type
    ut ? { id: ut.id, name: ut.name, slug: ut.slug } : nil
  end

  attribute :student, if: -> { object.aluno? } do
    s = object.student
    s ? { id: s.id, situacao: s.situacao } : nil
  end
end