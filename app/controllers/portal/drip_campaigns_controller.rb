module Portal
  class DripCampaignsController < BaseController
    before_action :set_campaign
    before_action :require_fan_crm_enabled
    before_action :set_drip, only: [:show, :edit, :update, :destroy, :toggle_status, :add_step, :remove_step, :update_step]

    def index
      @drips = @campaign.drip_campaigns.order(created_at: :desc)
    end

    def new
      @drip = @campaign.drip_campaigns.new
    end

    def create
      @drip = @campaign.drip_campaigns.new(drip_params)
      if @drip.save
        redirect_to portal_campaign_drip_campaign_path(@campaign, @drip), notice: 'Drip campaign created.'
      else
        render :new
      end
    end

    def show
      @steps = @drip.drip_steps.order(:position)
      @enrollments = @drip.drip_enrollments.includes(:contact).order(created_at: :desc).limit(50)
      @stats = {
        enrolled: @drip.enrolled_count,
        completed: @drip.completed_count,
        active: @drip.drip_enrollments.active.count,
        messages_sent: @drip.drip_messages.count,
        opened: @drip.drip_messages.where.not(opened_at: nil).count
      }
    end

    def edit
      @steps = @drip.drip_steps.order(:position)
    end

    def update
      if @drip.update(drip_params)
        redirect_to portal_campaign_drip_campaign_path(@campaign, @drip), notice: 'Drip campaign updated.'
      else
        @steps = @drip.drip_steps.order(:position)
        render :edit
      end
    end

    def destroy
      @drip.destroy
      redirect_to portal_campaign_drip_campaigns_path(@campaign), notice: 'Drip campaign deleted.'
    end

    def toggle_status
      case @drip.status
      when 'draft'  then @drip.active!
      when 'active' then @drip.paused!
      when 'paused' then @drip.active!
      end
      redirect_to portal_campaign_drip_campaign_path(@campaign, @drip), notice: "Status changed to #{@drip.status}."
    end

    def add_step
      position = @drip.drip_steps.maximum(:position).to_i + 1
      @drip.drip_steps.create!(
        position: position,
        delay_hours: params[:delay_hours].to_i,
        channel: params[:channel] || 'email',
        subject: params[:subject],
        body: params[:body]
      )
      redirect_to edit_portal_campaign_drip_campaign_path(@campaign, @drip), notice: 'Step added.'
    end

    def remove_step
      step = @drip.drip_steps.find(params[:step_id])
      step.destroy
      # Reorder remaining steps
      @drip.drip_steps.order(:position).each_with_index do |s, i|
        s.update_column(:position, i)
      end
      redirect_to edit_portal_campaign_drip_campaign_path(@campaign, @drip), notice: 'Step removed.'
    end

    def update_step
      step = @drip.drip_steps.find(params[:step_id])
      step.update!(
        delay_hours: params[:delay_hours].to_i,
        subject: params[:subject],
        body: params[:body],
        channel: params[:channel]
      )
      redirect_to edit_portal_campaign_drip_campaign_path(@campaign, @drip), notice: 'Step updated.'
    end

    private

    def require_fan_crm_enabled
      require_feature!('fan_crm')
    end

    def set_campaign
      @campaign = current_author.campaigns.find(params[:campaign_id])
    end

    def set_drip
      @drip = @campaign.drip_campaigns.find(params[:id])
    end

    def drip_params
      params.require(:drip_campaign).permit(:name, :trigger_event)
    end
  end
end
