class AddBustedIndicesToCells < ActiveRecord::Migration[5.0]
  def change
    add_index :cells, [:puzzle_id, :col, :possible, :symbol], :name => 'index_cells_on_puzzle_id_col_possible_symbol'
    add_index :cells, [:puzzle_id, :col, :possible, :row   ], :name => 'index_cells_on_puzzle_id_col_possible_row'
    add_index :cells, [:puzzle_id, :row, :possible, :symbol], :name => 'index_cells_on_puzzle_id_row_possible_symbol'
    add_index :cells, [:puzzle_id, :row, :possible, :col   ], :name => 'index_cells_on_puzzle_id_row_possible_col'
    add_index :cells, [:puzzle_id, :blk, :possible, :symbol], :name => 'index_cells_on_puzzle_id_blk_possible_symbol'
  end
end
