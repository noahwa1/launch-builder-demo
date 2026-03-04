module Portal
  class CampaignAssetsController < BaseController
    before_action :set_campaign

    def index
      @assets = @campaign.campaign_assets.order(created_at: :desc)
      @photos = @assets.where("asset_type LIKE ?", "photo_%")
      @videos = @assets.where("asset_type LIKE ?", "video_%")
    end

    def create
      @asset = @campaign.campaign_assets.build(asset_params)
      @asset.original_filename = params[:campaign_asset][:file]&.original_filename if params.dig(:campaign_asset, :file)

      if @asset.save
        redirect_to portal_campaign_campaign_assets_path(@campaign), notice: 'Asset uploaded successfully.'
      else
        @assets = @campaign.campaign_assets.order(created_at: :desc)
        @photos = @assets.where("asset_type LIKE ?", "photo_%")
        @videos = @assets.where("asset_type LIKE ?", "video_%")
        render :index
      end
    end

    def destroy
      asset = @campaign.campaign_assets.find(params[:id])
      asset.destroy
      redirect_to portal_campaign_campaign_assets_path(@campaign), notice: 'Asset removed.'
    end

    private

    def set_campaign
      @campaign = current_author.campaigns.find(params[:campaign_id])
    end

    def asset_params
      params.require(:campaign_asset).permit(:asset_type, :file)
    end
  end
end
