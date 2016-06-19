class CreateCells < ActiveRecord::Migration[5.0]
  def change
    create_table :cells do |t|
      t.integer :symbol
      t.integer :col
      t.integer :row
      t.integer :blk
      t.boolean :possible
      t.boolean :confirmed
      t.integer :source
      t.references :puzzle, foreign_key: true

      t.timestamps
    end
  end
end
