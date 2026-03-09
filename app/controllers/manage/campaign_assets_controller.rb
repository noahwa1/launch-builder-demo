module Manage
  class CampaignAssetsController < BaseController
    before_action :set_asset

    def approve
      @asset.update!(status: :approved, reviewed_by: current_user.id, reviewed_at: Time.current, admin_notes: nil)
      CampaignActivityLogger.asset_approved(@asset.campaign, @asset, current_user)
      NotificationService.asset_approved(@asset.campaign, @asset)
      PortalMailer.asset_approved(@asset).deliver_later
      redirect_to manage_campaign_path(@asset.campaign), notice: "Asset approved."
    end

    def request_changes
      @asset.update!(
        status: :needs_changes,
        reviewed_by: current_user.id,
        reviewed_at: Time.current,
        admin_notes: params[:admin_notes]
      )
      CampaignActivityLogger.asset_changes_requested(@asset.campaign, @asset, current_user)
      NotificationService.asset_changes_requested(@asset.campaign, @asset)
      PortalMailer.asset_needs_changes(@asset).deliver_later
      redirect_to manage_campaign_path(@asset.campaign), notice: "Changes requested."
    end

    private

    def set_asset
      @asset = CampaignAsset.find(params[:id])
    end
  end
end
