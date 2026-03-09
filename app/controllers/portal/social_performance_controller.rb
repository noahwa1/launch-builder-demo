module Portal
  class SocialPerformanceController < BaseController
    before_action :set_campaign
    before_action :require_social_tools_enabled

    def index
      @submission = @campaign.submission
      @author = @campaign.author
    end

    private

    def require_social_tools_enabled
      require_feature!('social_tools')
    end

    def set_campaign
      @campaign = current_author.campaigns.find(params[:campaign_id])
    end
  end
end
