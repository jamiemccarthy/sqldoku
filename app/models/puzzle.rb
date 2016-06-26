class SymbolIncompatibility < StandardError
  # TODO: an attr could provide info on whether row/col/blk/symbol caused error,
  # or even the source
end

class Puzzle < ApplicationRecord
  # TODO dependent => destroy does individual DELETEs; surely there's some
  # option that nukes based on the FK?
  has_many :cells, :autosave => true, :dependent => :destroy

  after_initialize :ensure_uuid
  validates :uuid, :uniqueness => true

  # Puzzle.root is the root size of the puzzle. Since each block, row, and col
  # must have root**2 cells, and each cell must have root**2 possible symbols,
  # the puzzle is root**2 cells on a side, with root**4 total cells, and
  # root**6 total possibilities.
  validates :root, :numericality => { :greater_than_or_equal_to => 2, :less_than_or_equal_to => 10 }

  def to_s
    rows = side.times.collect { [] }
    cells.is_confirmed.each { |c| rows[c.row-1][c.col-1] = c.symbol }
    uuid + "\n" + rows.map { |row| row.fill(nil, row.size, side-row.size).map { |c| c || '.' }.join(" ") }.join("\n")
  end

  def build_cells
    (1..side).each do |row|
      (1..side).each do |col|
        (1..side).each do |symbol|
          cells.build(:symbol => symbol, :col => col, :row => row, :blk => calculate_blk(col, row))
        end
      end
    end
    cells.size
  end

  def set!(col, row, symbol)
    blk = calculate_blk(col, row)
    Puzzle.transaction do
      # It may be more efficient to use the scopes to build a list of IDs,
      # then check-and-set that list.
      surrounding_scopes(col, row, symbol).each { |skope| bulk_impossible!(skope) }
      cells.with_symbol(symbol).in_col(col).in_row(row).each { |c| c.confirmed! }
    end
  end

  def confirmed_symbol(col, row)
    cells.in_col(col).in_row(row).is_confirmed.first.try(:symbol)
  end

  def side
    root**2
  end

  protected

  # This method encapsulates the logic at the heart of sudoku, which is that
  # defining a symbol locks down other symbols in four ways:
  #   * no other symbol is possible in that cell;
  #   * that same symbol cannot repeat in the same row, column, nor block.
  def surrounding_scopes(col, row, symbol)
    blk = calculate_blk(col, row)
    [
      cells.in_row(row).in_col(col).where.not(:symbol => symbol),
      cells.with_symbol(symbol).in_row(row).where.not(:col => col),
      cells.with_symbol(symbol).in_col(col).where.not(:row => row),
      cells.with_symbol(symbol).in_blk(blk).where.not(:col => col, :row => row)
    ]
  end

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def calculate_blk(col, row)
    1 + (((row-1)/root)*root + (col-1)/root)
  end

  def bulk_impossible!(skope)
    # We're bulk-setting these cells to "impossible," which means none of them
    # can be "confirmed." As an alternative, we could individually invoke
    # ".each { |cell| cell.impossible! }", which would raise the same error,
    # but this is slower than checking them all at once.
    raise SymbolIncompatibility unless skope.is_confirmed.count == 0
    skope.update_all(:possible => 0)
  end
end
