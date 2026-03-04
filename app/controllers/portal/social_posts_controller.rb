module Portal
  class SocialPostsController < BaseController
    before_action :set_campaign

    def index
      @submission = @campaign.submission
      @author = @campaign.author
      @landing_page = @campaign.landing_page
      @page_url = @landing_page&.slug.present? ? "/pages/#{@landing_page.slug}" : nil
      @signed_url = @campaign.signed_editions_url
    end

    private

    def set_campaign
      @campaign = current_author.campaigns.find(params[:campaign_id])
    end
  end
end
