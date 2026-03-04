class CampaignAsset < ApplicationRecord
  enum status: { pending_review: 0, approved: 1, needs_changes: 2 }

  belongs_to :campaign
  belongs_to :reviewer, class_name: 'User', foreign_key: :reviewed_by, optional: true

  mount_uploader :file, AssetUploader

  validates :asset_type, presence: true

  scope :pending, -> { where(status: :pending_review) }

  ASSET_TYPE_TO_CHECKLIST_KEY = {
    'photo_headshot'   => 'headshots_uploaded',
    'photo_candid'     => 'candid_photos_uploaded',
    'video_promo'      => 'promo_video_uploaded',
    'video_excerpt'    => 'excerpt_clips_uploaded',
    'video_signing'    => 'signing_clips_uploaded',
    'video_hook'       => 'hook_clips_uploaded',
  }.freeze

  after_save :update_checklist_item

  private

  def update_checklist_item
    checklist_key = ASSET_TYPE_TO_CHECKLIST_KEY[asset_type]
    return unless checklist_key

    item = campaign.checklist_items.find_by(key: checklist_key)
    return unless item

    # If any asset of this type is approved, mark complete
    if campaign.campaign_assets.where(asset_type: asset_type, status: :approved).exists?
      item.mark_complete!
    elsif campaign.campaign_assets.where(asset_type: asset_type).exists?
      item.mark_in_progress! unless item.complete?
    end
  end
end
