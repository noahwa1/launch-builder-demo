module Manage
  class LandingPagesController < BaseController
    before_action :set_campaign
    before_action :set_landing_page

    def show
      respond_to do |format|
        format.html { redirect_to manage_campaign_path(@campaign) }
        format.json { render json: { html_content: @landing_page.html_content, css_content: @landing_page.css_content } }
      end
    end

    def builder
      @admin_mode = true
      render 'portal/landing_pages/builder', layout: false
    end

    def wizard
      @admin_mode = true
      @wizard_data = build_wizard_data
      render 'manage/landing_pages/wizard', layout: false
    end

    def generate
      result = LandingPageGenerator.new(@campaign, template: params[:template] || 'standard').generate
      @landing_page.update!(html_content: result[:html], css_content: result[:css])
      redirect_to builder_manage_campaign_landing_page_path(@campaign), notice: 'Page generated! Customize it in the builder.'
    end

    def wizard_generate
      wizard_data = params.require(:wizard_data).permit!.to_h
      template = wizard_data['template'] || 'standard'
      result = LandingPageGenerator.new(@campaign, wizard_data: wizard_data).generate
      @landing_page.update!(html_content: result[:html], css_content: result[:css], wizard_template: template)
      redirect_to manage_campaign_path(@campaign), notice: 'Page generated from wizard!'
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
