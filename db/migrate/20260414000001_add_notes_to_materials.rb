class AddNotesToMaterials < ActiveRecord::Migration[8.0]
  def change
    add_column :materials, :notes, :text
  end
end
