module Manage
  class LiveEventsController < BaseController
    before_action :set_campaign

    def index
      @live_events = @campaign.live_events.recent
    end

    private

    def set_campaign
      @campaign = Campaign.find(params[:campaign_id])
    end
  end
end
