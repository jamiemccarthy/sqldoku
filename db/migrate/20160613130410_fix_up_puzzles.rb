class FixUpPuzzles < ActiveRecord::Migration[5.0]
  def up
    change_table :puzzles do |t|
      t.change :uuid, :string, :null => false
      t.change :solved, :boolean, :default => false, :null => false
    end
  end

  def down
    change_table :puzzles do |t|
      t.change :solved, :boolean, :null => true
      t.change :uuid, :string, :null => true
    end
  end
end
