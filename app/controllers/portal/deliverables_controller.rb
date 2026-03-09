module Portal
  class DeliverablesController < BaseController
    before_action :set_campaign
    before_action :require_deliverables_enabled
    before_action :set_deliverable, only: [:show, :approve, :request_revision, :add_note]

    def index
      @deliverables = @campaign.admin_deliverables.recent.includes(:creator)
      @pending = @campaign.admin_deliverables.pending
      @approved = @campaign.admin_deliverables.approved
    end

    def show
      @notes = @deliverable.deliverable_notes.recent.includes(:user)
    end

    def approve
      @deliverable.approved!
      @deliverable.deliverable_notes.create!(user: current_user, body: 'Approved') if @deliverable.deliverable_notes.none? { |n| n.body == 'Approved' && n.user_id == current_user.id }
      CampaignActivityLogger.deliverable_approved(@campaign, @deliverable, current_user)
      redirect_to portal_campaign_deliverable_path(@campaign, @deliverable), notice: 'Deliverable approved!'
    end

    def request_revision
      @deliverable.revision_requested!
      @deliverable.update!(creator_notes: params[:creator_notes]) if params[:creator_notes].present?
      if params[:creator_notes].present?
        @deliverable.deliverable_notes.create!(user: current_user, body: params[:creator_notes])
      end
      CampaignActivityLogger.deliverable_revision_requested(@campaign, @deliverable, current_user)
      redirect_to portal_campaign_deliverable_path(@campaign, @deliverable), notice: 'Revision requested — the team has been notified.'
    end

    def add_note
      @deliverable.deliverable_notes.create!(user: current_user, body: params[:body])
      redirect_to portal_campaign_deliverable_path(@campaign, @deliverable), notice: 'Note added.'
    end

    private

    def set_campaign
      @campaign = current_author.campaigns.find(params[:campaign_id])
    end

    def set_deliverable
      @deliverable = @campaign.admin_deliverables.find(params[:id])
    end

    def require_deliverables_enabled
      require_feature!('deliverables')
    end
  end
end
