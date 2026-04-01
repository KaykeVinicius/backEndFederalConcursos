class Event < ApplicationRecord
  enum :event_type, { aulao: 0, simulado: 1, workshop: 2, palestra: 3 }
  enum :status,     { agendado: 0, em_andamento: 1, concluido: 2, cancelado: 3 }

  belongs_to :course, optional: true

  validates :title,      presence: true
  validates :date,       presence: true
  validates :start_time, presence: true
  validates :end_time,   presence: true
end