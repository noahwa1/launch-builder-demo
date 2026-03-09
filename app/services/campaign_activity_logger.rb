module CampaignActivityLogger
  module_function

  def log(campaign, action:, user: nil, subject: nil, metadata: {})
    return unless campaign

    campaign.activities.create!(
      action: action,
      user: user,
      subject: subject,
      metadata: metadata
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("[CampaignActivityLogger] Failed to log #{action}: #{e.message}")
  end

  # Convenience methods for common events

  def asset_uploaded(campaign, asset, user)
    log(campaign, action: 'asset_uploaded', user: user, subject: asset,
        metadata: { asset_type: asset.asset_type, filename: asset.original_filename })
  end

  def asset_approved(campaign, asset, user)
    log(campaign, action: 'asset_approved', user: user, subject: asset,
        metadata: { filename: asset.original_filename })
  end

  def asset_changes_requested(campaign, asset, user)
    log(campaign, action: 'asset_changes_requested', user: user, subject: asset,
        metadata: { filename: asset.original_filename, notes: asset.admin_notes })
  end

  def deliverable_created(campaign, deliverable, user)
    log(campaign, action: 'deliverable_created', user: user, subject: deliverable,
        metadata: { title: deliverable.title, category: deliverable.category })
  end

  def deliverable_approved(campaign, deliverable, user)
    log(campaign, action: 'deliverable_approved', user: user, subject: deliverable,
        metadata: { title: deliverable.title })
  end

  def deliverable_revision_requested(campaign, deliverable, user)
    log(campaign, action: 'deliverable_revision_requested', user: user, subject: deliverable,
        metadata: { title: deliverable.title })
  end

  def deliverable_revised(campaign, deliverable, user)
    log(campaign, action: 'deliverable_revised', user: user, subject: deliverable,
        metadata: { title: deliverable.title, revision: deliverable.revision_count })
  end

  def section_confirmed(campaign, section, user)
    log(campaign, action: 'section_confirmed', user: user,
        metadata: { section: section })
  end

  def section_changes_requested(campaign, section, user, notes)
    log(campaign, action: 'section_changes_requested', user: user,
        metadata: { section: section, notes: notes })
  end

  def phase_advanced(campaign, from_phase, to_phase, user)
    log(campaign, action: 'phase_advanced', user: user,
        metadata: { from_phase: from_phase, to_phase: to_phase })
  end

  def phase_set(campaign, to_phase, user)
    log(campaign, action: 'phase_set', user: user,
        metadata: { to_phase: to_phase })
  end

  def checklist_toggled(campaign, item, user)
    log(campaign, action: 'checklist_toggled', user: user, subject: item,
        metadata: { title: item.title, new_status: item.status })
  end

  def landing_page_published(campaign, landing_page, user)
    log(campaign, action: 'landing_page_published', user: user, subject: landing_page,
        metadata: { slug: landing_page.slug })
  end

  def landing_page_unpublished(campaign, landing_page, user)
    log(campaign, action: 'landing_page_unpublished', user: user, subject: landing_page,
        metadata: { slug: landing_page.slug })
  end

  def event_went_live(campaign, event, user)
    log(campaign, action: 'event_went_live', user: user, subject: event,
        metadata: { title: event.title })
  end

  def event_ended(campaign, event, user)
    log(campaign, action: 'event_ended', user: user, subject: event,
        metadata: { title: event.title })
  end

  def submission_received(campaign, submission)
    log(campaign, action: 'submission_received', subject: submission,
        metadata: { form_type: submission.form_type, email: submission.email })
  end

  def campaign_created(campaign, user)
    log(campaign, action: 'campaign_created', user: user,
        metadata: { title: campaign.title, campaign_type: campaign.campaign_type })
  end
end
