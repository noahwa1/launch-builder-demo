module Manage
  class CampaignsController < BaseController
    before_action :set_campaign, only: [:show, :toggle_checklist_item]

    def index
      @campaigns = Campaign.includes(:author, :checklist_items, :campaign_assets)
                           .order(created_at: :desc)
                           .page(params[:page]).per(15)
    end

    def show
      @items_by_category = @campaign.items_by_category
      @pending_assets = @campaign.campaign_assets.pending.order(created_at: :desc)
      @all_assets = @campaign.campaign_assets.order(created_at: :desc)
    end

    def toggle_checklist_item
      item = @campaign.checklist_items.find(params[:checklist_item_id])
      if item.complete?
        item.reset!
      else
        item.mark_complete!
      end
      redirect_to manage_campaign_path(@campaign), notice: "\"#{item.title}\" updated."
    end

    private

    def set_campaign
      @campaign = Campaign.find(params[:id])
    end
  end
end
