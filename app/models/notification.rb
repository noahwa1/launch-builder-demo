class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :campaign

  validates :notification_type, presence: true
  validates :title, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def read?
    read_at.present?
  end

  def mark_read!
    update!(read_at: Time.current) unless read?
  end

  def time_ago
    seconds = Time.current - created_at
    case seconds
    when 0..59 then 'just now'
    when 60..3599 then "#{(seconds / 60).to_i}m ago"
    when 3600..86_399 then "#{(seconds / 3600).to_i}h ago"
    else "#{(seconds / 86_400).to_i}d ago"
    end
  end
end
