class Student < ApplicationRecord
  enum :situacao, { online: 0, presencial: 1, hibrido: 2 }

  belongs_to :user, optional: true
  belongs_to :city, optional: true

  has_many :enrollments
  has_many :courses,             through: :enrollments
  has_many :questions
  has_many :lesson_completions
  has_many :completed_lessons,   through: :lesson_completions, source: :lesson
  has_many :event_registrations

  validates :name,  presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :cpf,   presence: true, uniqueness: true,
                    format: { with: /\A\d{11}\z/, message: "deve conter exatamente 11 dígitos numéricos (sem pontos ou traços)" }
  validate :cpf_must_be_valid

  validates :whatsapp,
            format: { with: /\A\d{10,11}\z/, message: "deve conter 10 ou 11 dígitos numéricos (sem formatação)" },
            allow_blank: true

  # Garante que CPF e WhatsApp sejam salvos apenas com números
  before_validation :strip_cpf_and_whatsapp

  private

  def strip_cpf_and_whatsapp
    self.cpf      = cpf&.gsub(/\D/, "")
    self.whatsapp = whatsapp&.gsub(/\D/, "").presence
  end

  def cpf_must_be_valid
    return if cpf.blank? || cpf !~ /\A\d{11}\z/

    digits = cpf.chars.map(&:to_i)

    # Rejeita sequências repetidas (ex: 11111111111)
    if digits.uniq.length == 1
      errors.add(:cpf, "inválido")
      return
    end

    # Primeiro dígito verificador
    sum = digits[0..8].each_with_index.sum { |d, i| d * (10 - i) }
    remainder = (sum * 10) % 11
    remainder = 0 if remainder >= 10
    if remainder != digits[9]
      errors.add(:cpf, "inválido")
      return
    end

    # Segundo dígito verificador
    sum = digits[0..9].each_with_index.sum { |d, i| d * (11 - i) }
    remainder = (sum * 10) % 11
    remainder = 0 if remainder >= 10
    errors.add(:cpf, "inválido") if remainder != digits[10]
  end

  def enrolled_count_for_course(course_id)
    enrollments.where(course_id: course_id, status: :active).count
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name email cpf whatsapp active situacao street neighborhood cep created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user city enrollments courses]
  end
end