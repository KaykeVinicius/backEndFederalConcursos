class AddLoteIdToEventRegistrations < ActiveRecord::Migration[8.0]
  def change
    add_reference :event_registrations, :event_lote, null: true, foreign_key: true
  end
end
