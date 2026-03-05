class Campaign < ApplicationRecord
  enum status: { active: 0, paused: 1, completed: 2 }

  belongs_to :submission
  belongs_to :author
  belongs_to :book, optional: true
  has_many :checklist_items, dependent: :destroy
  has_many :campaign_assets, dependent: :destroy
  has_one :landing_page, dependent: :destroy
  has_many :live_events, dependent: :destroy
  has_many :personal_videos, dependent: :destroy

  mount_uploader :bookplate_design, AssetUploader

  validates :title, presence: true

  after_create :seed_checklist_items

  CHECKLIST_SEED = [
    { category: 'links',     key: 'signed_editions_url',            title: 'Signed editions URL configured',           optional: false, position: 0 },
    { category: 'links',     key: 'url_shared_social',              title: 'URL shared on social bios',                optional: false, position: 1 },
    { category: 'links',     key: 'url_added_linktree',             title: 'URL added to Linktree',                    optional: false, position: 2 },
    { category: 'ad_access', key: 'facebook_access',                title: 'Facebook page access granted',             optional: false, position: 0 },
    { category: 'ad_access', key: 'instagram_access',               title: 'Instagram page access granted',            optional: false, position: 1 },
    { category: 'ad_access', key: 'tiktok_access',                  title: 'TikTok access granted',                    optional: true,  position: 2 },
    { category: 'content',   key: 'headshots_uploaded',             title: 'High-res headshots uploaded',              optional: false, position: 0 },
    { category: 'content',   key: 'candid_photos_uploaded',         title: 'Casual/candid photos uploaded',            optional: false, position: 1 },
    { category: 'content',   key: 'promo_video_uploaded',           title: 'Promo video uploaded (30-60 sec)',         optional: false, position: 2 },
    { category: 'content',   key: 'excerpt_clips_uploaded',         title: 'Book excerpt clips uploaded',              optional: false, position: 3 },
    { category: 'content',   key: 'signing_clips_uploaded',         title: 'Signing clips uploaded',                   optional: false, position: 4 },
    { category: 'content',   key: 'hook_clips_uploaded',            title: 'Short hook clips uploaded',                optional: false, position: 5 },
    { category: 'logistics', key: 'shipping_address_confirmed',     title: 'Bookplate shipping address confirmed',     optional: false, position: 0 },
    { category: 'logistics', key: 'bookplate_design_uploaded',      title: 'Bookplate design file uploaded',           optional: false, position: 1 },
    { category: 'logistics', key: 'management_contacts_confirmed',  title: 'Management contact emails confirmed',      optional: false, position: 2 },
    { category: 'creative',  key: 'ad_creative_approved',           title: 'Ad creative approved',                     optional: false, position: 0 },
    { category: 'creative',  key: 'copy_approved',                  title: 'Copy approved',                            optional: false, position: 1 },
    { category: 'creative',  key: 'landing_page_built',             title: 'Landing page built',                       optional: true,  position: 2 },
  ].freeze

  CATEGORIES = %w[links ad_access content logistics creative].freeze

  EXAMPLE_CATEGORIES = %w[general political romance thriller fantasy nonfiction business children ya].freeze

  def onboarding_completed?
    onboarding_completed_at.present?
  end

  def complete_onboarding!
    update!(onboarding_completed_at: Time.current) unless onboarding_completed?
  end

  def progress_percentage
    required = checklist_items.where(optional: false)
    return 0 if required.empty?
    (required.where(status: :complete).count.to_f / required.count * 100).round
  end

  def current_live_event
    live_events.find_by(status: :live)
  end

  def next_scheduled_event
    live_events.upcoming.first
  end

  def is_live?
    live_events.where(status: :live).exists?
  end

  def items_by_category
    checklist_items.order(:position).group_by(&:category)
  end

  private

  def seed_checklist_items
    CHECKLIST_SEED.each do |item|
      checklist_items.create!(item)
    end
    create_landing_page!(title: title)
  end
end
