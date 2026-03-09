module Portal
  class SocialPerformanceController < BaseController
    before_action :set_campaign

    def index
      @submission = @campaign.submission
      @author = @campaign.author
    end

    private

    def set_campaign
      @campaign = current_author.campaigns.find(params[:campaign_id])
    end
  end
end
