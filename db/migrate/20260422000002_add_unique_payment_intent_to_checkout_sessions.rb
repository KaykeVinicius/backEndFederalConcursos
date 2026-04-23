class AddUniquePaymentIntentToCheckoutSessions < ActiveRecord::Migration[7.1]
  def change
    remove_index  :checkout_sessions, :payment_intent_id, if_exists: true
    add_index     :checkout_sessions, :payment_intent_id, unique: true, where: "payment_intent_id IS NOT NULL"
  end
end
