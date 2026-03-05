class PersonalVideo < ApplicationRecord
  belongs_to :campaign
  belongs_to :page_submission

  mount_uploader :file, AssetUploader

  enum status: { recorded: 0, sent: 1, failed: 2 }

  after_create :deliver_to_buyer

  private

  def deliver_to_buyer
    PortalMailer.personal_video_delivered(self).deliver_later
  end
end
