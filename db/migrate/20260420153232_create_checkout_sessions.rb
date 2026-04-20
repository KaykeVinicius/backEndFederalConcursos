class CreateCheckoutSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :checkout_sessions do |t|
      t.string   :reference_id,            null: false, index: { unique: true }
      t.string   :merchant_order_reference, null: false, index: { unique: true }
      t.string   :psp_reference_id
      t.references :course, null: false, foreign_key: true
      t.string   :status, null: false, default: "pending"
      t.jsonb    :customer_data, null: false, default: {}
      t.integer  :amount_cents, null: false
      t.integer  :duration_days, null: false, default: 365
      t.string   :payment_url
      t.timestamps
    end
  end
end
