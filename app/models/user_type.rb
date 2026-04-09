class UserType < ApplicationRecord
  has_many :users, dependent: :nullify

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true,
                   inclusion: { in: User.roles.keys.map(&:to_s) }

  scope :active,   -> { where(active: true) }
  scope :ordered,  -> { order(:position) }
end
