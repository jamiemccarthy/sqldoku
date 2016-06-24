class AddUniqueIndexToCell < ActiveRecord::Migration[5.0]
  def change
    add_index :cells, [:puzzle_id, :col, :row, :confirmed], unique: true
  end
end
