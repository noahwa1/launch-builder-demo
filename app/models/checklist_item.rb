class ChecklistItem < ApplicationRecord
  enum status: { not_started: 0, in_progress: 1, complete: 2 }

  belongs_to :campaign

  validates :title, presence: true
  validates :category, presence: true, inclusion: { in: Campaign::CATEGORIES }
  validates :key, uniqueness: { scope: :campaign_id }, allow_nil: true

  scope :required, -> { where(optional: false) }
  scope :incomplete, -> { where.not(status: :complete) }

  def mark_complete!
    update!(status: :complete, completed_at: Time.current)
  end

  def mark_in_progress!
    update!(status: :in_progress)
  end

  def reset!
    update!(status: :not_started, completed_at: nil)
  end
end
