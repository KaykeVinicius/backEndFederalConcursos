class Turma < ApplicationRecord
  enum :status, { aberta: 0, fechada: 1, em_andamento: 2 }

  belongs_to :course
  belongs_to :professor, class_name: "User", optional: true

  has_many :enrollments
  has_many :students,  through: :enrollments
  has_many :materials

  validates :name,       presence: true
  validates :start_date, presence: true
  validates :end_date,   presence: true

  def enrolled_count
    enrollments.where(status: :active).count
  end
end