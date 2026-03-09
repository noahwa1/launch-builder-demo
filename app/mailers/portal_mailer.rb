class PortalMailer < ApplicationMailer
  default from: 'portal@launch-publishing.com'

  def submission_received(submission)
    @submission = submission
    @author = submission.author
    mail(
      to: User.admin.pluck(:email),
      subject: "New submission: #{@submission.title} by #{@author.full_name}"
    )
  end

  def submission_approved(submission)
    @submission = submission
    @creator = submission.submitter
    mail(
      to: @creator.email,
      subject: "Your submission \"#{@submission.title}\" has been approved!"
    )
  end

  def submission_rejected(submission)
    @submission = submission
    @creator = submission.submitter
    mail(
      to: @creator.email,
      subject: "Update on your submission \"#{@submission.title}\""
    )
  end

  def new_message(message)
    @message = message
    @recipient = if message.sender.admin?
                   message.thread_owner
                 else
                   User.admin.first
                 end
    return unless @recipient

    mail(
      to: @recipient.email,
      subject: "New message from #{message.sender.full_name}"
    )
  end

  def campaign_created(campaign)
    @campaign = campaign
    @creator = campaign.author.user
    return unless @creator

    mail(
      to: @creator.email,
      subject: "Your campaign \"#{@campaign.title}\" is live!"
    )
  end

  def asset_approved(asset)
    @asset = asset
    @campaign = asset.campaign
    @creator = @campaign.author.user
    return unless @creator

    mail(
      to: @creator.email,
      subject: "Asset approved: #{@asset.original_filename || @asset.asset_type.titleize}"
    )
  end

  def asset_needs_changes(asset)
    @asset = asset
    @campaign = asset.campaign
    @creator = @campaign.author.user
    return unless @creator

    mail(
      to: @creator.email,
      subject: "Changes requested: #{@asset.original_filename || @asset.asset_type.titleize}"
    )
  end

  def build_requested(landing_page)
    @landing_page = landing_page
    @campaign = landing_page.campaign
    @author = @campaign.author
    mail(
      to: User.admin.pluck(:email),
      subject: "Build request: #{@campaign.title} landing page"
    )
  end

  def new_page_submission(submission)
    @submission = submission
    @landing_page = submission.landing_page
    @campaign = @landing_page.campaign
    @creator = @campaign.author.user
    return unless @creator

    mail(
      to: @creator.email,
      subject: "New form submission on your #{@campaign.title} landing page"
    )
  end

  def video_message(campaign_asset, recipient_email, message)
    @asset = campaign_asset
    @campaign = campaign_asset.campaign
    @author = @campaign.author
    @message = message
    @video_url = @asset.file&.url

    mail(
      to: recipient_email,
      subject: "A video message from #{@author.full_name} — #{@campaign.title}"
    )
  end

  def personal_video_delivered(personal_video)
    @personal_video = personal_video
    @campaign = personal_video.campaign
    @author = @campaign.author
    @submission = personal_video.page_submission
    @buyer_name = @submission.data&.dig('name') || @submission.data&.dig('first_name') || 'there'
    @video_url = personal_video.file&.url

    return unless @submission.email.present?

    mail(
      to: @submission.email,
      subject: "A personal video from #{@author.full_name} — #{@campaign.title}"
    )
  end

  def deliverable_ready(deliverable)
    @deliverable = deliverable
    @campaign = deliverable.campaign
    @creator = @campaign.author&.user
    return unless @creator

    mail(
      to: @creator.email,
      subject: "New deliverable ready for review: #{@deliverable.title}"
    )
  end

  def phase_advanced_notification(campaign, to_phase)
    @campaign = campaign
    @to_phase = to_phase
    @creator = @campaign.author&.user
    return unless @creator

    mail(
      to: @creator.email,
      subject: "Your campaign has moved to the #{@to_phase.titleize} phase"
    )
  end

  def deadline_approaching(campaign, deadline_name, days_left)
    @campaign = campaign
    @deadline_name = deadline_name
    @days_left = days_left
    @creator = @campaign.author&.user
    return unless @creator

    mail(
      to: @creator.email,
      subject: "#{@deadline_name} is in #{@days_left} #{'day'.pluralize(@days_left)}"
    )
  end

  def notification_email(notification)
    @notification = notification
    @user = notification.user
    @campaign = notification.campaign
    return unless @user

    mail(
      to: @user.email,
      subject: notification.title
    )
  end

  def payment_processed(payment)
    @payment = payment
    @author = payment.author
    @creator = @author.user
    return unless @creator

    mail(
      to: @creator.email,
      subject: "Royalty payment of $#{@payment.amount} has been processed"
    )
  end
end
