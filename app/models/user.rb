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

  belongs_to :user_type, optional: true

  # Sincroniza role a partir do user_type quando user_type_id mudar
  before_validation :sync_role_from_user_type

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

  # Gera um novo session_token — invalida todas as sessões anteriores
  def rotate_session_token!
    self.session_token = SecureRandom.hex(32)
    save!(validate: false)
    session_token
  end

  # Gera token de configuração de senha (válido por 7 dias)
  def generate_setup_token!
    self.setup_password_token            = SecureRandom.urlsafe_base64(32)
    self.setup_password_token_expires_at = 7.days.from_now
    save!(validate: false)
    setup_password_token
  end

  def setup_token_valid?(token)
    setup_password_token.present? &&
      setup_password_token == token &&
      setup_password_token_expires_at > Time.current
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name email cpf role active created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user_type student]
  end

  private

  def sync_role_from_user_type
    self.role = user_type.slug if user_type.present? && user_type.slug.present?
  end
end