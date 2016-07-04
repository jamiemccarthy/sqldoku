class SymbolIncompatibility < StandardError
  # TODO: an attr could provide info on whether row/col/blk/symbol caused error,
  # or even the source
end

class PuzzleUnsolvable < StandardError
  # Used internally when making guesses.
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
    format_as_text { |rows| cells.is_confirmed.each { |c| rows[c.row-1][c.col-1] = c.symbol } }
  end

  def to_heatmap
    heatmap = cells.is_possible_but_unconfirmed.group(:row, :col).count
    format_as_text { |rows| heatmap.each_key { |k| row, col = k; rows[row-1][col-1] = heatmap[k] > 0 ? heatmap[k] : '.' } }
  end

  def solve!(max_depth: 1, indent: "")
    return self if solved
    # Find list of locations that haven't yet been solved, in a rough order
    # of how "easy" it seems to solve them.
    possibilities = cells.is_possible_but_unconfirmed.
      group(:col, :row).
      order('count_all ASC, row ASC, col ASC').count
    # If there aren't any, the puzzle is already solved.
    return self if possibilities.blank?
    # If we still have work to do, but we've run out of depth, quit.
    puts indent + "ran out of depth" if max_depth <= 0
    raise PuzzleUnsolvable if max_depth <= 0
    # For each location in the list, set a SAVEPOINT, make a guess at its symbol,
    # and recursively try to solve the resulting puzzle. If that fails (can it?)
    # and we still have more guesses, try them too. If we run out of guesses, quit.
    puts indent + "Trying to solve this..."
    puts to_s.gsub(/^/, indent)
    puts to_heatmap.gsub(/^/, indent)
    possibilities.keys.each do |location|
      col, row = location
      puts indent + "Looking at #{col},#{row}..."
      possible_symbols = cells.is_possible.in_col(col).in_row(row).pluck(:symbol)
      possible_symbols.each do |symbol|
        puts indent + "Trying #{symbol} at #{col},#{row}..."
        Puzzle.transaction(requires_new: true) do
          begin
            set!(col, row, symbol)
            # If solve! returns, it's solved the puzzle.
            return solve!(max_depth: max_depth - 1, indent: indent + "   ")
          rescue SymbolIncompatibility
            puts indent + "SymbolIncompatibility... that's unexpected... bug maybe?"
            puts indent + "Raising Rollback."
            raise ActiveRecord::Rollback
          rescue PuzzleUnsolvable
            puts indent + "Okay, that didn't work: it resulted in:"
            puts to_s.gsub(/^/, indent)
            puts to_heatmap.gsub(/^/, indent)
            puts indent + "Raising Rollback."
            raise ActiveRecord::Rollback
          end
        end
      end
    end
    puts indent + "Can't find a solution, PuzzleUnsolvable in the depth requested..."
    raise PuzzleUnsolvable
  end

  def solve_one!
    return self if solved
    col, row, symbol = nil
    # If there's any location where only one symbol is possible, set it.
    col, row = cells.is_possible_but_unconfirmed.group(:col, :row).having('count_all = 1').count.first.try(:first)
    if col && row
      symbol = cells.is_possible.in_col(col).in_row(row).first.symbol
      puts "Setting #{symbol} at #{col},#{row} because no other symbol possible"
    else
      # If there's any symbol whose confirmed + possible count add up
      # to exactly "side," then all remaining possible must be true
      symbol_confirmed = cells.is_possible.group(:symbol, :confirmed).count
      (1..side).each do |sym|
        unconfirmed_count = symbol_confirmed[[sym, nil]]
        confirmed_count = symbol_confirmed[[sym, true]]
        if unconfirmed_count.present? && confirmed_count.present? &&
          unconfirmed_count > 0 && unconfirmed_count+confirmed_count == side
          cell = cells.is_possible_but_unconfirmed.with_symbol(sym).first
          col, row, symbol = cell.col, cell.row, sym
          puts "Setting #{symbol} at #{col},#{row} because it has to go in the remaining #{unconfirmed_count} locations"
          break
        end
      end
    end
    raw_single_set!(col, row, symbol) if col && row && symbol
  end

  def ensure_cells_built!
    # The logic of this class depends on the data being in a SQL database.
    build_cells unless self.cells_built
  end

  def build_cells
    return if self.cells_built
    (1..side).each do |row|
      (1..side).each do |col|
        (1..side).each do |symbol|
          cells.build(:symbol => symbol, :col => col, :row => row, :blk => calculate_blk(col, row))
        end
      end
    end
    self.cells_built = true
    save!
    cells.size
  end

  def set!(col, row, symbol)
    raw_single_set!(col, row, symbol)
    1 while solve_one!
  end

  def confirmed_symbol(col, row)
    ensure_cells_built!
    cells.in_col(col).in_row(row).is_confirmed.first.try(:symbol)
  end

  def side
    root**2
  end

  protected

  def raw_single_set!(col, row, symbol)
    ensure_cells_built!
    blk = calculate_blk(col, row)
    Puzzle.transaction do
      # It may be more efficient to use the scopes to build a list of IDs,
      # then check-and-set that list.
      surrounding_scopes(col, row, symbol).each { |skope| bulk_impossible!(skope) }
      busted_scopes(col, row).each { |skope| raise PuzzleUnsolvable if skope.count.present? }
      cells.with_symbol(symbol).in_col(col).in_row(row).each { |c| c.confirmed! }
    end
    self
  end

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

  # This method provides the scopes which must always be empty. If any
  # reveal there are no possibilities, that scope is "busted" and
  # the puzzle is not solvable.
  # (For root=3 puzzles, it'd almost certainly be more efficient to do this
  # across the whole puzzle at once, but as root increases, targeted checks
  # would become more efficient.)
  def busted_scopes(col, row)
    blk = calculate_blk(col, row)
    puts "checking busted_scopes for #{col},#{row}"
    [
      cells.is_impossible.in_col(col).group(:symbol).having('count_all = ?', side),
      cells.is_impossible.in_col(col).group(:row   ).having('count_all = ?', side),
      cells.is_impossible.in_row(row).group(:symbol).having('count_all = ?', side),
      cells.is_impossible.in_row(row).group(:col   ).having('count_all = ?', side),
      cells.is_impossible.in_blk(blk).group(:symbol).having('count_all = ?', side),
    ]
  end

  def format_as_text
    rows = side.times.collect { [] }
    yield(rows)
    width = rows.flatten.compact.max.to_s.length || 1
    uuid + "\n" +
      rows.map do |row|
        row.fill(nil, row.size, side-row.size).map do |c|
          sprintf("%#{width}s", c || '.' )
        end.join(" ")
      end.join("\n")
  end

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def calculate_blk(col, row)
    1 + (((row-1)/root)*root + (col-1)/root)
  end

  def bulk_impossible!(skope)
    ensure_cells_built!
    # We're bulk-setting these cells to "impossible," which means none of them
    # can be "confirmed." As an alternative, we could individually invoke
    # ".each { |cell| cell.impossible! }", which would raise the same error,
    # but this is slower than checking them all at once.
    raise SymbolIncompatibility unless skope.is_confirmed.count == 0
    skope.update_all(:possible => 0)
  end
end
