module Portal
  class SocialCalendarController < BaseController
    before_action :set_campaign

    def index
      @submission = @campaign.submission
      @author = @campaign.author
      @month = params[:month] ? Date.parse(params[:month]) : Date.today
      @scheduled_posts = @campaign.scheduled_posts.for_month(@month).order(:scheduled_at)
    end

    private

    def set_campaign
      @campaign = current_author.campaigns.find(params[:campaign_id])
    end
  end
end
