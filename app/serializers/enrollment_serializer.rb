class EnrollmentSerializer < ActiveModel::Serializer
  attributes :id, :status, :started_at, :expires_at, :enrollment_type,
             :payment_method, :total_paid, :contract_signed, :created_at

  belongs_to :student, serializer: StudentSerializer
  belongs_to :course,  serializer: CourseSerializer
  belongs_to :turma,   serializer: TurmaSerializer
  belongs_to :career,  serializer: CareerSerializer
end