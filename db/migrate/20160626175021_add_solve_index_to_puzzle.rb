class AddSolveIndexToPuzzle < ActiveRecord::Migration[5.0]
  def change
    add_index :cells, [:puzzle_id, :possible, :confirmed, :col, :row], :name => 'index_cells_on_puzzle_id_possible_confirmed_col_row'
  end
end
