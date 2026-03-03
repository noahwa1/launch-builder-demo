class RoyaltyRate < ApplicationRecord
  belongs_to :author
  belongs_to :book, optional: true

  validates :rate, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 1 }
  validates :effective_from, presence: true

  scope :active, -> { where(effective_to: nil) }
  scope :for_author, ->(author) { where(author: author) }

  def percentage
    (rate * 100).round(2)
  end

  def active?
    effective_to.nil?
  end
end
