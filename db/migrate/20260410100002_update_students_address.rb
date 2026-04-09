class UpdateStudentsAddress < ActiveRecord::Migration[8.0]
  def change
    # Rename generic address field to street
    rename_column :students, :address, :street

    # Add separate address columns
    add_column :students, :address_number,    :string
    add_column :students, :address_complement, :string
    add_column :students, :neighborhood,      :string
    add_column :students, :cep,               :string

    # Link to cities table
    add_reference :students, :city, foreign_key: true, null: true
  end
end
