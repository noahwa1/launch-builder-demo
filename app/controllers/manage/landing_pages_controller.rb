module Manage
  class LandingPagesController < BaseController
    before_action :set_campaign
    before_action :set_landing_page

    def builder
      @admin_mode = true
      render 'portal/landing_pages/builder', layout: false
    end

    def generate
      result = LandingPageGenerator.new(@campaign, template: params[:template] || 'standard').generate
      @landing_page.update!(html_content: result[:html], css_content: result[:css])
      redirect_to builder_manage_campaign_landing_page_path(@campaign), notice: 'Page generated! Customize it in the builder.'
    end

    def toggle_notifications
      @landing_page.update!(notify_on_submission: !@landing_page.notify_on_submission?)
      status = @landing_page.notify_on_submission? ? 'enabled' : 'disabled'
      redirect_to manage_campaign_path(@campaign), notice: "Submission notifications #{status}."
    end

    def update
      if @landing_page.update(landing_page_params)
        render json: { success: true }
      else
        render json: { success: false, errors: @landing_page.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_campaign
      @campaign = Campaign.find(params[:campaign_id])
    end

    def set_landing_page
      @landing_page = @campaign.landing_page || @campaign.create_landing_page!(title: @campaign.title)
    end

    def landing_page_params
      params.require(:landing_page).permit(:title, :html_content, :css_content)
    end
  end
end
