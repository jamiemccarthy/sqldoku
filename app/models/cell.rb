class Cell < ApplicationRecord
  belongs_to :puzzle, :touch => true

  scope :with_symbol, ->(symbol) { where(:symbol => symbol) }
  scope :in_col, ->(c) { where(:col => c) }
  scope :in_row, ->(r) { where(:row => r) }
  scope :in_blk, ->(b) { where(:blk => b) }
  scope :is_possible, -> { where(:possible => 1) }
  scope :is_confirmed, -> { where(:confirmed => 1) }
  scope :natural_order, -> { order(:col => :asc, :row => :asc, :symbol => :asc) }

  def impossible!
    # This check must be performed in Ruby, because there's no database integrity
    # check (and I think no good way to design such a check in MySQL) that
    # would prevent an already-confirmed symbol from being set to impossible.
    raise SymbolIncompatibility if confirmed
    update(:possible => 0)
  end

  def confirmed!
    # This check must also be performed in Ruby, for basically the same reason.
    raise SymbolIncompatibility unless possible
    update(:confirmed => 1)
  end
end
