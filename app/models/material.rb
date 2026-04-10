class Material < ApplicationRecord
  enum :material_type, { pdf: 0, slide: 1, exercicio: 2, link: 3 }

  belongs_to :professor, class_name: "User"
  belongs_to :subject,   optional: true
  belongs_to :turma,     optional: true

  has_one_attached :file

  validates :title, presence: true
end