module Manage
  class AdminDeliverablesController < BaseController
    before_action :set_campaign
    before_action :require_deliverables_enabled
    before_action :set_deliverable, only: [:show, :edit, :update, :destroy, :revise, :add_note]

    def index
      @deliverables = @campaign.admin_deliverables.recent.includes(:creator)
      @pending_count = @campaign.admin_deliverables.pending.count
      @revision_count = @campaign.admin_deliverables.needs_revision.count
    end

    def show
      @notes = @deliverable.deliverable_notes.recent.includes(:user)
    end

    def new
      @deliverable = @campaign.admin_deliverables.new
    end

    def create
      @deliverable = @campaign.admin_deliverables.new(deliverable_params)
      @deliverable.created_by = current_user.id
      if @deliverable.save
        CampaignActivityLogger.deliverable_created(@campaign, @deliverable, current_user)
        NotificationService.deliverable_ready(@campaign, @deliverable)
        redirect_to manage_campaign_admin_deliverable_path(@campaign, @deliverable), notice: 'Deliverable created and sent to creator for review.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @deliverable.update(deliverable_params)
        redirect_to manage_campaign_admin_deliverable_path(@campaign, @deliverable), notice: 'Deliverable updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @deliverable.destroy
      redirect_to manage_campaign_admin_deliverables_path(@campaign), notice: 'Deliverable deleted.'
    end

    def revise
      @deliverable.file = params[:file] if params[:file].present?
      @deliverable.revision_count += 1
      @deliverable.status = :revised
      @deliverable.save!

      if params[:note].present?
        @deliverable.deliverable_notes.create!(user: current_user, body: params[:note])
      end

      CampaignActivityLogger.deliverable_revised(@campaign, @deliverable, current_user)
      NotificationService.deliverable_revised(@campaign, @deliverable)
      redirect_to manage_campaign_admin_deliverable_path(@campaign, @deliverable), notice: 'Revised version uploaded.'
    end

    def add_note
      @deliverable.deliverable_notes.create!(user: current_user, body: params[:body])
      redirect_to manage_campaign_admin_deliverable_path(@campaign, @deliverable), notice: 'Note added.'
    end

    # Cross-campaign view of all deliverables needing attention
    def needs_attention
      @deliverables = AdminDeliverable.needs_revision.recent.includes(:campaign, :creator)
    end

    private

    def set_campaign
      @campaign = Campaign.find(params[:campaign_id]) if params[:campaign_id].present?
    end

    def set_deliverable
      @deliverable = @campaign.admin_deliverables.find(params[:id])
    end

    def require_deliverables_enabled
      return unless @campaign
      unless @campaign.deliverables_enabled?
        redirect_to manage_campaign_path(@campaign), alert: 'Deliverables are not enabled for this campaign.'
      end
    end

    def deliverable_params
      params.require(:admin_deliverable).permit(:title, :description, :category, :file, :due_date)
    end
  end
end
