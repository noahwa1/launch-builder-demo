class PortalMessage < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :thread_owner, class_name: 'User'
  belongs_to :submission, optional: true

  validates :body, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :unread, -> { where(read_at: nil) }
  scope :general, -> { where(submission_id: nil) }

  def read?
    read_at.present?
  end

  def mark_read!
    update!(read_at: Time.current) unless read?
  end
end
