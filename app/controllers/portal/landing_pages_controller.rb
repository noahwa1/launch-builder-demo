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

    def wizard
      @admin_mode = false
      @wizard_data = build_wizard_data
      render 'manage/landing_pages/wizard', layout: false
    end

    def wizard_generate
      wizard_data = params.require(:wizard_data).permit!.to_h
      template = wizard_data['template'] || 'standard'
      result = LandingPageGenerator.new(@campaign, wizard_data: wizard_data).generate
      @landing_page.update!(html_content: result[:html], css_content: result[:css], wizard_template: template)
      redirect_to portal_campaign_landing_page_path(@campaign), notice: 'Page generated from wizard!'
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
      CampaignActivityLogger.landing_page_published(@campaign, @landing_page, current_user)
      redirect_to portal_campaign_landing_page_path(@campaign), notice: "Page published at /pages/#{@landing_page.slug}"
    end

    def unpublish
      @landing_page.unpublish!
      CampaignActivityLogger.landing_page_unpublished(@campaign, @landing_page, current_user)
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

    def build_wizard_data
      {
        template: @landing_page.wizard_template || 'standard',
        hero: {
          headline: @campaign.submission&.title,
          subheadline: "by #{@campaign.author&.full_name}",
          cta_text: LandingPageGenerator::TEMPLATE_CTA[@landing_page.wizard_template || 'standard'],
          cta_url: @campaign.signed_editions_url
        },
        book: {
          title: @campaign.submission&.title,
          description: @campaign.submission&.description,
          genre: @campaign.submission&.genre,
          release_date: @campaign.submission&.release_date&.strftime('%B %d, %Y')
        },
        author: {
          name: @campaign.author&.full_name,
          bio: @campaign.author&.description
        },
        retailers: LandingPageGenerator::DEFAULT_RETAILERS.map { |r| r.stringify_keys },
        steps: (LandingPageGenerator::TEMPLATE_STEPS[@landing_page.wizard_template || 'personalized_video'] || []).map { |s| s.stringify_keys },
        testimonials: LandingPageGenerator::DEFAULT_TESTIMONIAL.map { |t| t.stringify_keys },
        bonuses: LandingPageGenerator::DEFAULT_BONUSES.map { |b| b.stringify_keys }
      }
    end
  end
end
