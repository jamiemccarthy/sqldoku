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
    raise ArgumentError if confirmed
    update(:possible => 0)
  end

  def confirmed!
    raise ArgumentError unless possible
    update(:confirmed => 1)
  end
end
