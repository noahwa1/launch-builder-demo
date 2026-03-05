module Manage
  class DashboardController < BaseController
    def index
      @total_campaigns = Campaign.count
      @active_campaigns = Campaign.active.count
      @active_authors = Author.active.count
      @pending_assets = CampaignAsset.pending.count
      @unread_messages = unread_admin_message_count
      @total_paid = RoyaltyPayment.where(status: :paid).sum(:amount)

      @recent_campaigns = Campaign.includes(:author).order(created_at: :desc).limit(10)
      @recent_assets = CampaignAsset.includes(:campaign).order(created_at: :desc).limit(5)
    end
  end
end
