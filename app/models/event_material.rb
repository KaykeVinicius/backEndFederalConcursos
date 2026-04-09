class EventMaterial < ApplicationRecord
  belongs_to :event
  belongs_to :subject
  belongs_to :professor, class_name: "User"

  has_one_attached :file

  validates :title, presence: true
  validates :expires_at, presence: true

  scope :available, -> { where("expires_at > ?", Time.current) }

  before_validation :set_expiry, on: :create

  private

  def set_expiry
    self.expires_at ||= (event.date + 1.day).end_of_day if event
  end
end
