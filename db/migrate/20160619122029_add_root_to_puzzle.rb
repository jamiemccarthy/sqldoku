class AddRootToPuzzle < ActiveRecord::Migration[5.0]
  def change
    add_column :puzzles, :root, :integer, :default => 3, :null => false
  end
end
