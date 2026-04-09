class User < ApplicationRecord
  has_secure_password

  enum :role, {
    ceo: 0,
    assistente_comercial: 1,
    equipe_pedagogica: 2,
    professor: 3,
    aluno: 4,
    diretor: 5
  }

  has_one  :student
  has_many :subjects_taught,  class_name: "Subject",  foreign_key: :professor_id
  has_many :turmas_managed,   class_name: "Turma",    foreign_key: :professor_id
  has_many :questions_received, class_name: "Question", foreign_key: :professor_id
  has_many :materials,        foreign_key: :professor_id
  has_many :notifications,    dependent: :destroy

  validates :name,  presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :cpf,   presence: true, uniqueness: true
  validates :role,  presence: true

  def professor?
    role == "professor"
  end

  def aluno?
    role == "aluno"
  end
end