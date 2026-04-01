class CreateContracts < ActiveRecord::Migration[8.0]
  def change
    create_table :contracts do |t|
      t.references :enrollment, null: false, foreign_key: true
      t.references :student,    null: false, foreign_key: true
      t.references :course,     null: false, foreign_key: true
      t.text    :contract_text
      t.string  :version,       null: false, default: "1.0"
      t.datetime :signed_at
      t.integer  :status,       null: false, default: 0
      t.string   :pdf_url

      t.timestamps
    end
  end
end