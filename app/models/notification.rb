class Notification < ApplicationRecord
  belongs_to :user

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(30) }

  def read?
    read_at.present?
  end

  # Cria notificações para todos os usuários ativos exceto o criador
  def self.broadcast(notifiable:, title:, body: nil, except_user_id: nil)
    users = User.where(active: true)
    users = users.where.not(id: except_user_id) if except_user_id

    records = users.map do |u|
      {
        user_id:         u.id,
        notifiable_type: notifiable.class.name,
        notifiable_id:   notifiable.id,
        title:           title,
        body:            body,
        created_at:      Time.current,
        updated_at:      Time.current,
      }
    end

    insert_all(records) if records.any?
  end
end
