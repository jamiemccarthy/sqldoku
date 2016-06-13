class CreatePuzzles < ActiveRecord::Migration[5.0]
  def change
    create_table :puzzles do |t|
      t.string :uuid
      t.timestamps :null => false
      t.boolean :solved
    end
    add_index :puzzles, :uuid, unique: true
  end
end
