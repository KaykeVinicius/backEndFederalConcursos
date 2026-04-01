class CreateEnrollments < ActiveRecord::Migration[8.0]
  def change
    create_table :enrollments do |t|
      t.references :student,  null: false, foreign_key: true
      t.references :course,   null: false, foreign_key: true
      t.references :turma,    null: false, foreign_key: true
      t.references :career,   null: true,  foreign_key: true
      t.integer  :status,             null: false, default: 0
      t.date     :started_at,         null: false
      t.date     :expires_at
      t.integer  :enrollment_type,    null: false, default: 0
      t.string   :payment_method
      t.integer  :total_paid_cents,   null: false, default: 0
      t.boolean  :contract_signed,    null: false, default: false

      t.timestamps
    end
  end
end