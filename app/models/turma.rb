class Turma < ApplicationRecord
  enum :status, { aberta: 0, fechada: 1, em_andamento: 2 }

  belongs_to :course
  belongs_to :professor, class_name: "User", optional: true

  has_many :enrollments
  has_many :students,        through: :enrollments
  has_many :materials
  has_many :turma_class_days, dependent: :destroy

  validates :name,       presence: true
  validates :start_date, presence: true
  validates :end_date,   presence: true
  validates :modalidade, inclusion: { in: %w[presencial hibrido] }
  validate  :course_must_not_be_online

  def enrolled_count
    enrollments.where(status: :active).count
  end

  def auto_close_if_full!
    update_column(:status, :fechada) if enrolled_count >= max_students && status != "fechada"
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name status modalidade shift start_date end_date created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[course professor]
  end

  private

  def course_must_not_be_online
    return unless course
    if course.online?
      errors.add(:base, "Cursos online não possuem turmas. Turmas são exclusivas de cursos presenciais e híbridos.")
    end
  end
end
