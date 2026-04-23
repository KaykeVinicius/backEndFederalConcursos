class User < ApplicationRecord
  has_secure_password

  belongs_to :user_type

  has_one  :student
  has_many :professor_subjects, foreign_key: :professor_id, dependent: :destroy
  has_many :subjects_taught, through: :professor_subjects, source: :subject
  has_many :turmas_managed,   class_name: "Turma",    foreign_key: :professor_id
  has_many :questions_received, class_name: "Question", foreign_key: :professor_id
  has_many :materials,        foreign_key: :professor_id
  has_many :notifications,    dependent: :destroy

  validates :name,      presence: true
  validates :email,     presence: true, uniqueness: { case_sensitive: false }
  validates :cpf,       presence: true, uniqueness: true
  validates :user_type, presence: true

  # Delega role para o slug do user_type — elimina a coluna redundante
  def role
    user_type&.slug
  end

  def professor?
    role == "professor"
  end

  def aluno?
    role == "aluno"
  end

  def active?
    active
  end

  # Gera um novo session_token — invalida todas as sessões anteriores
  def rotate_session_token!
    self.session_token = SecureRandom.hex(32)
    save!(validate: false)
    session_token
  end

  # Gera token de configuração de senha (válido por 7 dias — para novo usuário)
  def generate_setup_token!
    self.setup_password_token            = SecureRandom.urlsafe_base64(32)
    self.setup_password_token_expires_at = 7.days.from_now
    save!(validate: false)
    setup_password_token
  end

  # Gera token de redefinição de senha (válido por 2 horas — para esqueceu senha)
  def generate_reset_token!
    self.setup_password_token            = SecureRandom.urlsafe_base64(32)
    self.setup_password_token_expires_at = 2.hours.from_now
    save!(validate: false)
    setup_password_token
  end

  def setup_token_valid?(token)
    setup_password_token.present? &&
      setup_password_token == token &&
      setup_password_token_expires_at > Time.current
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name email cpf active created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user_type student]
  end
end
