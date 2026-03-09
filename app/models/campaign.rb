class Campaign < ApplicationRecord
  enum status: { active: 0, paused: 1, completed: 2 }
  enum phase: { setup: 0, content: 1, review: 2, live: 3, wrap_up: 4 }

  belongs_to :submission
  belongs_to :author
  belongs_to :book, optional: true
  has_many :checklist_items, dependent: :destroy
  has_many :campaign_assets, dependent: :destroy
  has_one :landing_page, dependent: :destroy
  has_many :live_events, dependent: :destroy
  has_many :personal_videos, dependent: :destroy
  has_many :scheduled_posts, dependent: :destroy
  has_many :contacts, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :drip_campaigns, dependent: :destroy
  has_many :referral_codes, dependent: :destroy
  has_many :admin_deliverables, dependent: :destroy
  has_many :creator_confirmations, dependent: :destroy
  has_many :activities, class_name: 'CampaignActivity', dependent: :destroy
  has_many :notifications, dependent: :destroy

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
    { category: 'content',   key: 'headshots_uploaded',             title: 'High-res headshots',                       optional: true, position: 0 },
    { category: 'content',   key: 'candid_photos_uploaded',         title: 'Casual/candid photos',                    optional: true, position: 1 },
    { category: 'content',   key: 'promo_video_uploaded',           title: 'Promo video (30-60 sec)',                  optional: true, position: 2 },
    { category: 'content',   key: 'excerpt_clips_uploaded',         title: 'Book excerpt clips',                      optional: true, position: 3 },
    { category: 'content',   key: 'signing_clips_uploaded',         title: 'Signing clips',                           optional: true, position: 4 },
    { category: 'content',   key: 'hook_clips_uploaded',            title: 'Short hook clips',                        optional: true, position: 5 },
    { category: 'logistics', key: 'shipping_address_confirmed',     title: 'Bookplate shipping address confirmed',     optional: false, position: 0 },
    { category: 'logistics', key: 'bookplate_design_uploaded',      title: 'Bookplate design file uploaded',           optional: false, position: 1 },
    { category: 'logistics', key: 'management_contacts_confirmed',  title: 'Management contact emails confirmed',      optional: false, position: 2 },
    { category: 'creative',  key: 'ad_creative_approved',           title: 'Ad creative approved',                     optional: false, position: 0 },
    { category: 'creative',  key: 'copy_approved',                  title: 'Copy approved',                            optional: false, position: 1 },
    { category: 'creative',  key: 'landing_page_built',             title: 'Landing page built',                       optional: true,  position: 2 },
  ].freeze

  CATEGORIES = %w[links ad_access content logistics creative].freeze

  EXAMPLE_CATEGORIES = %w[general political romance thriller fantasy nonfiction business children ya].freeze

  CAMPAIGN_TYPES = {
    'landing_page_only' => {
      label: 'Landing Page Only',
      description: 'Landing page and sales/royalty data only',
      flags: {
        landing_page_enabled: true,
        asset_uploads_enabled: false,
        deliverables_enabled: false,
        live_events_enabled: false,
        personal_videos_enabled: false,
        social_tools_enabled: false,
        fan_crm_enabled: false,
        royalties_enabled: true
      }
    },
    'standard' => {
      label: 'Standard Launch',
      description: 'Campaign checklist, asset uploads, deliverable review, and landing page',
      flags: {
        landing_page_enabled: true,
        asset_uploads_enabled: true,
        deliverables_enabled: true,
        live_events_enabled: false,
        personal_videos_enabled: false,
        social_tools_enabled: true,
        fan_crm_enabled: true,
        royalties_enabled: true
      }
    },
    'full' => {
      label: 'Full Experience',
      description: 'Everything enabled — live events, personal videos, social tools, the works',
      flags: {
        landing_page_enabled: true,
        asset_uploads_enabled: true,
        deliverables_enabled: true,
        live_events_enabled: true,
        personal_videos_enabled: true,
        social_tools_enabled: true,
        fan_crm_enabled: true,
        royalties_enabled: true
      }
    }
  }.freeze

  FEATURE_FLAGS = %w[
    landing_page asset_uploads deliverables
    live_events personal_videos social_tools fan_crm royalties
  ].freeze

  def apply_campaign_type!(type_key)
    config = CAMPAIGN_TYPES[type_key]
    return unless config
    update!(campaign_type: type_key, **config[:flags])
  end

  CONFIRMABLE_SECTIONS = %w[links ad_access logistics brief].freeze

  def section_confirmed?(section)
    creator_confirmations.exists?(section: section)
  end

  def confirmation_for(section)
    creator_confirmations.find_by(section: section)
  end

  def confirmable_sections
    CONFIRMABLE_SECTIONS
  end

  def confirmation_progress
    return 0 if confirmable_sections.empty?
    confirmed = confirmable_sections.count { |s| section_confirmed?(s) }
    (confirmed.to_f / confirmable_sections.size * 100).round
  end

  PHASE_LABELS = {
    'setup'   => 'Setup',
    'content' => 'Content',
    'review'  => 'Review',
    'live'    => 'Live',
    'wrap_up' => 'Wrap Up'
  }.freeze

  def phase_complete?
    phase_blockers.empty?
  end

  def advance_phase!
    return unless phase_complete?
    next_index = self.class.phases[phase] + 1
    next_phase = self.class.phases.key(next_index)
    update!(phase: next_phase) if next_phase
  end

  def can_advance?
    phase_complete? && phase != 'wrap_up'
  end

  def phase_blockers
    case phase.to_sym
    when :setup
      blockers = []
      confirmable_sections.each do |s|
        conf = confirmation_for(s)
        blockers << "#{s.titleize} not confirmed" unless conf&.persisted? && !conf.has_changes_requested?
      end
      blockers

    when :content
      blockers = []
      if deliverables_enabled?
        pending_del = admin_deliverables.pending
        blockers << "#{pending_del.count} deliverables awaiting review" if pending_del.any?
      end
      blockers

    when :review
      blockers = []
      incomplete = checklist_items.required.incomplete
      blockers << "#{incomplete.count} checklist items incomplete" if incomplete.any?
      if deliverables_enabled?
        needs_rev = admin_deliverables.needs_revision
        blockers << "#{needs_rev.count} deliverables need revision" if needs_rev.any?
      end
      if landing_page_enabled?
        blockers << "Landing page not published" unless landing_page&.published?
      end
      blockers

    else
      []
    end
  end

  def skip_empty_phases!
    while phase_blockers.empty? && !%w[live wrap_up].include?(phase)
      advance_phase!
    end
  end

  def phase_label
    PHASE_LABELS[phase] || phase.titleize
  end

  def feature_enabled?(feature)
    respond_to?("#{feature}_enabled?") ? send("#{feature}_enabled?") : true
  end

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
      next if item[:category] == 'content' && !asset_uploads_enabled?
      next if item[:category] == 'creative' && !deliverables_enabled?
      next if item[:key] == 'landing_page_built' && !landing_page_enabled?
      checklist_items.create!(item)
    end
    create_landing_page!(title: title) if landing_page_enabled?
  end
end
