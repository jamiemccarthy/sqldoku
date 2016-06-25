class AddPcIndexToCells < ActiveRecord::Migration[5.0]
  def change
    add_index :cells, [:puzzle_id, :confirmed]
  end
end
