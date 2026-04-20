class CheckoutSession < ApplicationRecord
  belongs_to :course

  enum :status, {
    pending:   "pending",
    completed: "completed",
    cancelled: "cancelled",
    failed:    "failed"
  }, prefix: true

  validates :reference_id, presence: true, uniqueness: true
  validates :merchant_order_reference, presence: true, uniqueness: true
  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :customer_data, presence: true

  def customer_name  = customer_data["name"]
  def customer_cpf   = customer_data["cpf"]
  def customer_email = customer_data["email"]
  def customer_phone = customer_data["whatsapp"]
end
