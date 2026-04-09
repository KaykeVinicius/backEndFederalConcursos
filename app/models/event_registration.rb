class EventRegistration < ApplicationRecord
  belongs_to :event
  belongs_to :student
  belongs_to :event_lote, optional: true

  before_create :generate_ticket_token

  validates :student_id, uniqueness: { scope: :event_id, message: "já está inscrito neste evento" }

  def mark_attended!
    update!(attended: true, attended_at: Time.current)
  end

  private

  def generate_ticket_token
    self.ticket_token = SecureRandom.uuid
  end
end
