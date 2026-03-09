class CampaignActivity < ApplicationRecord
  belongs_to :campaign
  belongs_to :user, optional: true
  belongs_to :subject, polymorphic: true, optional: true

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_date, -> { order(created_at: :desc) }

  # Actions visible to creators in the portal (excludes internal admin actions)
  PORTAL_VISIBLE_ACTIONS = %w[
    asset_uploaded asset_approved asset_changes_requested
    deliverable_created deliverable_approved deliverable_revision_requested deliverable_revised
    section_confirmed section_changes_requested
    phase_advanced
    landing_page_published landing_page_unpublished
    event_went_live event_ended
    submission_received
    campaign_created
  ].freeze

  # Actions that require specific feature flags to be visible
  FEATURE_GATED_ACTIONS = {
    'asset_uploaded' => 'asset_uploads',
    'asset_approved' => 'asset_uploads',
    'asset_changes_requested' => 'asset_uploads',
    'deliverable_created' => 'deliverables',
    'deliverable_approved' => 'deliverables',
    'deliverable_revision_requested' => 'deliverables',
    'deliverable_revised' => 'deliverables',
    'landing_page_published' => 'landing_page',
    'landing_page_unpublished' => 'landing_page',
    'event_went_live' => 'live_events',
    'event_ended' => 'live_events',
    'submission_received' => 'landing_page',
  }.freeze

  def portal_visible?
    PORTAL_VISIBLE_ACTIONS.include?(action)
  end

  def feature_gated?
    FEATURE_GATED_ACTIONS.key?(action)
  end

  def visible_for_campaign?(camp = campaign)
    return false unless portal_visible?
    return true unless feature_gated?
    camp.feature_enabled?(FEATURE_GATED_ACTIONS[action])
  end

  def user_initials
    return '?' unless user
    "#{user.first_name&.first}#{user.last_name&.first}".upcase.presence || '?'
  end

  def human_description
    case action
    when 'campaign_created'
      'Campaign was created'
    when 'asset_uploaded'
      "Uploaded #{metadata['asset_type']&.titleize || 'an asset'}"
    when 'asset_approved'
      "Approved asset: #{metadata['filename'] || 'file'}"
    when 'asset_changes_requested'
      "Requested changes on asset: #{metadata['filename'] || 'file'}"
    when 'deliverable_created'
      "Created deliverable: #{metadata['title'] || 'item'}"
    when 'deliverable_approved'
      "Approved deliverable: #{metadata['title'] || 'item'}"
    when 'deliverable_revision_requested'
      "Requested revision on: #{metadata['title'] || 'item'}"
    when 'deliverable_revised'
      "Uploaded revised version: #{metadata['title'] || 'item'}"
    when 'section_confirmed'
      "Confirmed #{metadata['section']&.titleize || 'section'}"
    when 'section_changes_requested'
      "Requested changes to #{metadata['section']&.titleize || 'section'}"
    when 'phase_advanced'
      "Campaign advanced to #{metadata['to_phase']&.titleize || 'next phase'}"
    when 'phase_set'
      "Phase manually set to #{metadata['to_phase']&.titleize || 'phase'}"
    when 'checklist_toggled'
      status = metadata['new_status'] == 'complete' ? 'Completed' : 'Reset'
      "#{status}: #{metadata['title'] || 'checklist item'}"
    when 'landing_page_published'
      'Landing page published'
    when 'landing_page_unpublished'
      'Landing page unpublished'
    when 'event_went_live'
      "Went live: #{metadata['title'] || 'event'}"
    when 'event_ended'
      "Ended stream: #{metadata['title'] || 'event'}"
    when 'submission_received'
      "New #{metadata['form_type']&.titleize || 'form'} submission received"
    else
      action.titleize
    end
  end
end
