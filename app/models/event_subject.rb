class EventSubject < ApplicationRecord
  belongs_to :event
  belongs_to :subject

  validates :event_id, uniqueness: { scope: :subject_id }
end
