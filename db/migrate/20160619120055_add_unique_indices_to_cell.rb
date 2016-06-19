class AddUniqueIndicesToCell < ActiveRecord::Migration[5.0]
  def change
    remove_column :cells, :updated_at, :timestamp
    remove_column :cells, :created_at, :timestamp
    add_index :cells, [:puzzle_id, :row, :col, :symbol], unique: true
    add_index :cells, [:puzzle_id, :row, :symbol, :confirmed], unique: true
    add_index :cells, [:puzzle_id, :col, :symbol, :confirmed], unique: true
    add_index :cells, [:puzzle_id, :blk, :symbol, :confirmed], unique: true
    change_column_default :cells, :possible, :from => nil, :to => 1
    change_column_null :cells, :possible, false
  end
end
