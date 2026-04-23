class AddPaymentIntentToCheckoutSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :checkout_sessions, :payment_intent_id, :string
    add_index  :checkout_sessions, :payment_intent_id
  end
end
