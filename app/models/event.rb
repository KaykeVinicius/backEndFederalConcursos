class Event < ApplicationRecord
  enum :event_type, { aulao: 0, simulado: 1 }
  enum :status,     { agendado: 0, em_andamento: 1, concluido: 2, cancelado: 3 }

  belongs_to :course, optional: true
  has_many :event_lotes,         dependent: :destroy
  has_many :event_registrations, dependent: :destroy
  has_many :students,            through: :event_registrations
  has_many :event_subjects,      dependent: :destroy
  has_many :subjects,            through: :event_subjects
  has_many :event_materials,     dependent: :destroy

  def full?
    registered_count >= max_participants
  end

  def current_lote
    event_lotes.order(:position).find(&:available?)
  end

  validates :title,      presence: true
  validates :date,       presence: true
  validates :start_time, presence: true
  validates :end_time,   presence: true
end