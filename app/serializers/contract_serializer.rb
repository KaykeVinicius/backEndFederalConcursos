class ContractSerializer < ActiveModel::Serializer
  attributes :id, :version, :signed_at, :status, :pdf_url, :contract_text, :created_at

  belongs_to :enrollment
  belongs_to :student,  serializer: StudentSerializer
  belongs_to :course,   serializer: CourseSerializer
end