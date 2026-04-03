class AddModalidadeToTurmas < ActiveRecord::Migration[8.0]
  def change
    add_column :turmas, :modalidade, :string, default: "presencial", null: false
  end
end
