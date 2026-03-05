module Portal
  class LiveEventsController < BaseController
    before_action :set_campaign
    before_action :set_live_event, only: [:edit, :update, :destroy, :go_live, :end_stream]

    def studio
      @current_live_event = @campaign.current_live_event
      @next_event = @campaign.next_scheduled_event
      @upcoming_events = @campaign.live_events.upcoming.limit(5)
      @past_events = @campaign.live_events.where(status: :ended).order(ended_at: :desc).limit(10)
      @new_event = @campaign.live_events.new
      @submission = @campaign.submission
      @landing_page = @campaign.landing_page
    end

    def new
      @live_event = @campaign.live_events.new
    end

    def create
      @live_event = @campaign.live_events.new(live_event_params)
      if @live_event.save
        redirect_to portal_campaign_path(@campaign), notice: 'Event scheduled!'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @live_event.update(live_event_params)
        redirect_to portal_campaign_path(@campaign), notice: 'Event updated.'
      else
        render :edit
      end
    end

    def destroy
      @live_event.destroy
      redirect_to portal_campaign_path(@campaign), notice: 'Event removed.'
    end

    def go_live
      @live_event.go_live!
      redirect_to portal_campaign_path(@campaign), notice: 'You are LIVE! Your landing page now shows the stream.'
    end

    def end_stream
      @live_event.end_stream!
      redirect_to portal_campaign_path(@campaign), notice: 'Stream ended.'
    end

    private

    def set_campaign
      @campaign = current_author.campaigns.find(params[:campaign_id])
    end

    def set_live_event
      @live_event = @campaign.live_events.find(params[:id])
    end

    def live_event_params
      params.require(:live_event).permit(:title, :description, :embed_url, :stream_platform, :scheduled_at)
    end
  end
end
