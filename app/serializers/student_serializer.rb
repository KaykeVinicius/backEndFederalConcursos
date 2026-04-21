class StudentSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :whatsapp, :cpf, :instagram,
             :street, :address_number, :address_complement, :neighborhood, :cep,
             :internal, :active, :situacao, :created_at,
             :city_id, :birth_date

  belongs_to :user, serializer: UserSerializer

  attribute :city do
    c = object.city
    c ? { id: c.id, name: c.name, state: c.state } : nil
  end

  attribute :enrollments, if: -> { object.association(:enrollments).loaded? } do
    object.enrollments.map do |e|
      {
        id:               e.id,
        status:           e.status,
        started_at:       e.started_at,
        expires_at:       e.expires_at,
        enrollment_type:  e.enrollment_type,
        payment_method:   e.payment_method,
        total_paid:       e.total_paid,
        contract_signed:  e.contract_signed,
        created_at:       e.created_at,
        course:           e.course ? { id: e.course.id, title: e.course.title } : nil,
        turma:            e.turma  ? { id: e.turma.id,  name:  e.turma.name  } : nil,
      }
    end
  end
end
