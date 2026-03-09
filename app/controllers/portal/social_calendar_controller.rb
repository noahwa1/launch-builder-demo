module Portal
  class SocialCalendarController < BaseController
    before_action :set_campaign
    before_action :require_social_tools_enabled

    def index
      @submission = @campaign.submission
      @author = @campaign.author
      @month = params[:month] ? Date.parse(params[:month]) : Date.today
      @scheduled_posts = @campaign.scheduled_posts.for_month(@month).order(:scheduled_at)
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
