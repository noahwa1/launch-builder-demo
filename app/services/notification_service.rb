module NotificationService
  # High-priority types that trigger email
  EMAIL_TYPES = %w[
    deliverable_ready
    asset_changes_requested
    deadline_approaching
    phase_advanced
  ].freeze

  # Feature flag requirements per notification type
  FEATURE_GATES = {
    'deliverable_ready'    => 'deliverables',
    'deliverable_revised'  => 'deliverables',
    'asset_approved'       => 'asset_uploads',
    'asset_changes_requested' => 'asset_uploads',
    'submission_received'  => 'landing_page',
  }.freeze

  module_function

  def notify(user:, campaign:, type:, title:, body: nil, url: nil)
    return unless user

    # Check feature gate
    if FEATURE_GATES[type]
      return unless campaign.feature_enabled?(FEATURE_GATES[type])
    end

    notification = Notification.create!(
      user: user,
      campaign: campaign,
      notification_type: type,
      title: title,
      body: body,
      url: url
    )

    # Queue email for high-priority types
    if EMAIL_TYPES.include?(type) && user.email_on_notification?
      PortalMailer.notification_email(notification).deliver_later
    end

    notification
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("[NotificationService] Failed to create notification: #{e.message}")
    nil
  end

  # Convenience methods called from controllers alongside CampaignActivityLogger

  def deliverable_ready(campaign, deliverable)
    creator = campaign.author&.user
    notify(
      user: creator,
      campaign: campaign,
      type: 'deliverable_ready',
      title: "New #{deliverable.category&.titleize || 'deliverable'} ready for review",
      body: "\"#{deliverable.title}\" has been added by your team and needs your review.",
      url: "/portal/campaigns/#{campaign.id}/deliverables/#{deliverable.id}"
    )
  end

  def deliverable_revised(campaign, deliverable)
    creator = campaign.author&.user
    notify(
      user: creator,
      campaign: campaign,
      type: 'deliverable_revised',
      title: "Revised version uploaded: #{deliverable.title}",
      body: "Your team uploaded revision ##{deliverable.revision_count} of \"#{deliverable.title}\".",
      url: "/portal/campaigns/#{campaign.id}/deliverables/#{deliverable.id}"
    )
  end

  def asset_approved(campaign, asset)
    creator = campaign.author&.user
    notify(
      user: creator,
      campaign: campaign,
      type: 'asset_approved',
      title: "#{asset.asset_type&.titleize || 'Asset'} approved",
      body: "\"#{asset.original_filename || 'Your upload'}\" has been approved.",
      url: "/portal/campaigns/#{campaign.id}/campaign_assets"
    )
  end

  def asset_changes_requested(campaign, asset)
    creator = campaign.author&.user
    notify(
      user: creator,
      campaign: campaign,
      type: 'asset_changes_requested',
      title: "Changes requested on #{asset.original_filename || asset.asset_type&.titleize || 'asset'}",
      body: asset.admin_notes.presence || "Your team has requested changes on this upload.",
      url: "/portal/campaigns/#{campaign.id}/campaign_assets"
    )
  end

  def phase_advanced(campaign, to_phase)
    creator = campaign.author&.user
    notify(
      user: creator,
      campaign: campaign,
      type: 'phase_advanced',
      title: "Campaign moved to #{to_phase.titleize} phase",
      body: "Your campaign \"#{campaign.title}\" has advanced to the #{to_phase.titleize} phase.",
      url: "/portal/campaigns/#{campaign.id}"
    )
  end

  def submission_received(campaign, submission)
    creator = campaign.author&.user
    notify(
      user: creator,
      campaign: campaign,
      type: 'submission_received',
      title: "New #{submission.form_type&.titleize || 'form'} submission",
      body: "#{submission.email || 'Someone'} submitted a form on your landing page.",
      url: "/portal/campaigns/#{campaign.id}/landing_page"
    )
  end

  def message_received(campaign, message, recipient)
    notify(
      user: recipient,
      campaign: campaign,
      type: 'message_received',
      title: "New message from #{message.sender.first_name || 'your team'}",
      body: message.body.truncate(120),
      url: "/portal/messages"
    )
  end

  def deadline_approaching(campaign, deadline_name, days_left)
    creator = campaign.author&.user
    notify(
      user: creator,
      campaign: campaign,
      type: 'deadline_approaching',
      title: "#{deadline_name} is in #{days_left} #{'day'.pluralize(days_left)}",
      body: "Your #{deadline_name.downcase} for \"#{campaign.title}\" is coming up on #{campaign.send(deadline_name.parameterize(separator: '_'))&.strftime('%B %d')}.",
      url: "/portal/campaigns/#{campaign.id}"
    )
  end
end
