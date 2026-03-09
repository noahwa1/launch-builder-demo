module Manage
  class DashboardController < BaseController
    def index
      @total_campaigns = Campaign.count
      @active_campaigns = Campaign.active.count
      @active_authors = Author.active.count
      @pending_assets = CampaignAsset.pending.count
      @unread_messages = unread_admin_message_count
      @total_paid = RoyaltyPayment.where(status: :paid).sum(:amount)

      # Campaigns grouped by phase
      @campaigns_by_phase = Campaign.active.group(:phase).count
      Campaign.phases.each_key { |p| @campaigns_by_phase[p] ||= 0 }

      # Deliverables needing admin action (revision_requested across all campaigns)
      @revision_deliverables = AdminDeliverable.needs_revision.includes(:campaign).recent.limit(10) if defined?(AdminDeliverable)

      # Upcoming deadlines across all campaigns
      @upcoming_deadlines = Campaign.active
        .where('launch_date > ? OR content_deadline > ? OR review_deadline > ?', Date.today, Date.today, Date.today)
        .order(Arel.sql('COALESCE(content_deadline, review_deadline, launch_date)'))
        .limit(8)

      @recent_campaigns = Campaign.includes(:author).order(created_at: :desc).limit(10)
      @recent_assets = CampaignAsset.includes(:campaign).order(created_at: :desc).limit(5)
    end
  end
end
