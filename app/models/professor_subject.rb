class ProfessorSubject < ApplicationRecord
  belongs_to :professor, class_name: "User"
  belongs_to :subject

  validates :professor_id, uniqueness: { scope: :subject_id }
end
