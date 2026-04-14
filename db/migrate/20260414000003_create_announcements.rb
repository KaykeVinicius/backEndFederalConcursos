class CreateAnnouncements < ActiveRecord::Migration[8.0]
  def change
    create_table :announcements do |t|
      t.string   :title,    null: false
      t.text     :body,     null: false
      t.integer  :category, null: false, default: 0  # enum: geral, urgente, evento, financeiro, pedagogico
      t.integer  :audience, null: false, default: 0  # enum: todos, alunos, professores, equipe
      t.boolean  :pinned,   null: false, default: false
      t.boolean  :active,   null: false, default: true
      t.datetime :expires_at
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :announcements, :pinned
    add_index :announcements, :active
    add_index :announcements, :category
    add_index :announcements, :audience
  end
end
