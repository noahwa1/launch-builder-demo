class ScheduledPost < ApplicationRecord
  belongs_to :campaign

  mount_uploader :image, AssetUploader

  enum status: { draft: 0, scheduled: 1, posted: 2 }

  validates :platform, presence: true, inclusion: { in: %w[instagram tiktok twitter facebook] }
  validates :body, presence: true
  validates :scheduled_at, presence: true, if: :scheduled?

  scope :for_month, ->(date) {
    where(scheduled_at: date.beginning_of_month.beginning_of_day..date.end_of_month.end_of_day)
  }

  scope :upcoming, -> { where('scheduled_at >= ?', Time.current).order(:scheduled_at) }
end
