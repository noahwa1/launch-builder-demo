class RoyaltyStatement < ApplicationRecord
  belongs_to :royalty_payment
  belongs_to :book

  validates :units_sold, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  def calculate_royalty
    return unless gross_revenue && royalty_rate
    self.royalty_amount = (gross_revenue * royalty_rate).round(2)
  end
end
