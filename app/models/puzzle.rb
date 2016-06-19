class Puzzle < ApplicationRecord
  # Puzzle.root is the root size of the puzzle. Since each block, row, and col
  # must have root**2 cells, and each cell must have root**2 possible symbols,
  # the puzzle is root**2 cells on a side, with root**4 total cells, and
  # root**6 total possibilities.
end
