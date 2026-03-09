class AdminDeliverable < ApplicationRecord
  enum status: { pending_review: 0, approved: 1, revision_requested: 2, revised: 3 }

  belongs_to :campaign
  belongs_to :creator, class_name: 'User', foreign_key: :created_by
  has_many :deliverable_notes, dependent: :destroy

  mount_uploader :file, AssetUploader

  validates :title, presence: true
  validates :category, presence: true

  scope :pending, -> { where(status: [:pending_review, :revised]) }
  scope :needs_revision, -> { where(status: :revision_requested) }
  scope :recent, -> { order(created_at: :desc) }

  CATEGORIES = %w[ad_creative social_post copy email_draft landing_page_mockup video_edit other].freeze

  def category_label
    category&.titleize
  end

  def status_color
    case status
    when 'pending_review' then '#D97706'
    when 'approved'       then '#16A34A'
    when 'revision_requested' then '#EF4444'
    when 'revised'        then '#6366F1'
    else '#9CA3AF'
    end
  end

  def needs_attention?
    pending_review? || revised?
  end
end
