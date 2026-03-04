module Manage
  class PageSubmissionsController < BaseController
    before_action :set_campaign
    before_action :set_submission, only: :show

    def index
      @submissions = @campaign.landing_page&.page_submissions&.recent || PageSubmission.none
    end

    def show
    end

    private

    def set_campaign
      @campaign = Campaign.find(params[:campaign_id])
    end

    def set_submission
      @submission = @campaign.landing_page.page_submissions.find(params[:id])
    end
  end
end
