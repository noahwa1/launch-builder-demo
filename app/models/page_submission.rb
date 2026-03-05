class PageSubmission < ApplicationRecord
  belongs_to :landing_page
  has_one :personal_video

  enum status: { new_submission: 0, reviewed: 1, actioned: 2 }

  mount_uploader :receipt, ReceiptUploader

  validates :form_type, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
