class RoyaltyPayment < ApplicationRecord
  enum status: { pending: 0, processing: 1, paid: 2, cancelled: 3 }

  belongs_to :author
  has_many :royalty_statements, dependent: :destroy

  accepts_nested_attributes_for :royalty_statements, allow_destroy: true, reject_if: :all_blank

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :period_start, presence: true
  validates :period_end, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def period_label
    "#{period_start.strftime('%b %Y')} - #{period_end.strftime('%b %Y')}"
  end

  def mark_paid!(reference = nil)
    update!(status: :paid, paid_at: Time.current, reference: reference)
  end
end
