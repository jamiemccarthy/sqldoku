class AddSymbolCountIndexToCells < ActiveRecord::Migration[5.0]
  def change
    add_index :cells, [:puzzle_id, :possible, :symbol, :confirmed], :name => 'index_cells_on_puzzle_id_possible_symbol_confirmed'
  end
end
