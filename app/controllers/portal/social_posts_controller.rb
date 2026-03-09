module Portal
  class SocialPostsController < BaseController
    before_action :set_campaign
    before_action :require_social_tools_enabled

    def index
      @submission = @campaign.submission
      @author = @campaign.author
      @landing_page = @campaign.landing_page
      @page_url = @landing_page&.slug.present? ? "/pages/#{@landing_page.slug}" : nil
      @signed_url = @campaign.signed_editions_url
      @photo_assets = @campaign.campaign_assets.where("asset_type LIKE ?", "photo_%").order(created_at: :desc)
    end

    def schedule
      post = @campaign.scheduled_posts.new(scheduled_post_params)

      # If an existing campaign asset was selected, copy its file
      if params[:asset_id].present? && !params.dig(:scheduled_post, :image)
        asset = @campaign.campaign_assets.find_by(id: params[:asset_id])
        if asset&.file&.file
          post.image = File.open(asset.file.file.file)
        end
      end

      if post.save
        render json: { success: true, post: { id: post.id, platform: post.platform, category: post.category, body: post.body, scheduled_at: post.scheduled_at, status: post.status } }
      else
        render json: { success: false, errors: post.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def require_social_tools_enabled
      require_feature!('social_tools')
    end

    def scheduled_post_params
      params.require(:scheduled_post).permit(:platform, :category, :body, :scheduled_at, :status, :image)
    end

    def set_campaign
      @campaign = current_author.campaigns.find(params[:campaign_id])
    end
  end
end
