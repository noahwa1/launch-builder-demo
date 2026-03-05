module Portal
  class LandingPagesController < BaseController
    before_action :set_campaign
    before_action :set_landing_page

    def show
      @submissions = @landing_page.page_submissions.recent.limit(10)
      respond_to do |format|
        format.html
        format.json { render json: { html_content: @landing_page.html_content, css_content: @landing_page.css_content } }
      end
    end

    def builder
      render layout: false
    end

    def update
      if @landing_page.update(landing_page_params)
        respond_to do |format|
          format.html do
            if params[:redirect_to_builder]
              redirect_to builder_portal_campaign_landing_page_path(@campaign)
            else
              redirect_to portal_campaign_landing_page_path(@campaign), notice: 'Landing page saved.'
            end
          end
          format.json { render json: { success: true } }
        end
      else
        respond_to do |format|
          format.html { render :show }
          format.json { render json: { success: false, errors: @landing_page.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    def publish
      @landing_page.publish!
      redirect_to portal_campaign_landing_page_path(@campaign), notice: "Page published at /pages/#{@landing_page.slug}"
    end

    def unpublish
      @landing_page.unpublish!
      redirect_to portal_campaign_landing_page_path(@campaign), notice: 'Page unpublished.'
    end

    def generate
      result = LandingPageGenerator.new(@campaign, template: params[:template] || 'standard').generate
      @landing_page.update!(
        html_content: result[:html],
        css_content: result[:css],
        slug: params.dig(:landing_page, :slug).presence || @landing_page.slug
      )
      redirect_to builder_portal_campaign_landing_page_path(@campaign), notice: 'Page generated! Customize it in the builder.'
    end

    def request_build
      @landing_page.request_build!
      PortalMailer.build_requested(@landing_page).deliver_later
      redirect_to portal_campaign_landing_page_path(@campaign), notice: 'Build request sent to Premiere!'
    end

    private

    def set_campaign
      @campaign = current_author.campaigns.find(params[:campaign_id])
    end

    def set_landing_page
      @landing_page = @campaign.landing_page || @campaign.create_landing_page!(title: @campaign.title)
    end

    def landing_page_params
      params.require(:landing_page).permit(:title, :html_content, :css_content, :slug)
    end
  end
end
