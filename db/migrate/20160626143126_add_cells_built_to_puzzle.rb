class AddCellsBuiltToPuzzle < ActiveRecord::Migration[5.0]
  def change
    add_column :puzzles, :cells_built, :boolean, :default => false
  end
end
