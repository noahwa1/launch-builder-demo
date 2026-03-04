class Submission < ApplicationRecord
  enum status: { draft: 0, submitted: 1, in_review: 2, approved: 3, live: 4, rejected: 5 }

  belongs_to :author
  belongs_to :submitter, class_name: 'User', foreign_key: :submitted_by
  belongs_to :reviewer, class_name: 'User', foreign_key: :reviewed_by, optional: true
  has_many :portal_messages
  has_one :campaign

  mount_uploader :cover, CoverUploader

  validates :title, presence: true

  scope :pending_review, -> { where(status: [:submitted, :in_review]) }
  scope :recent, -> { order(created_at: :desc) }

  def submit!
    update!(status: :submitted, submitted_at: Time.current)
  end

  def approve!(admin)
    update!(status: :approved, reviewed_by: admin.id, reviewed_at: Time.current)
    create_campaign_on_approval
  end

  def reject!(admin, notes)
    update!(status: :rejected, reviewed_by: admin.id, reviewed_at: Time.current, admin_notes: notes)
  end

  def mark_in_review!(admin)
    update!(status: :in_review, reviewed_by: admin.id)
  end

  private

  def create_campaign_on_approval
    return if campaign.present?
    Campaign.create!(
      submission: self,
      author: author,
      title: title
    )
    PortalMailer.campaign_created(campaign.reload).deliver_later
  end
end
