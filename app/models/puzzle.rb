class Puzzle < ApplicationRecord
  has_many :cells, :autosave => true

  after_initialize :ensure_uuid
  validates :uuid, :uniqueness => true

  # Puzzle.root is the root size of the puzzle. Since each block, row, and col
  # must have root**2 cells, and each cell must have root**2 possible symbols,
  # the puzzle is root**2 cells on a side, with root**4 total cells, and
  # root**6 total possibilities.
  validates :root, :numericality => { :greater_than_or_equal_to => 2, :less_than_or_equal_to => 10 }

  def build_cells
    (1..root**2).each do |row|
      (1..root**2).each do |col|
        (1..root**2).each do |symbol|
          cells.build(:symbol => symbol, :col => col, :row => row, :blk => calculate_blk(col, row))
        end
      end
    end
  end

  protected

  def calculate_blk(col, row)
    1 + (((row-1)/root)*root + (col-1)/root)
  end

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
