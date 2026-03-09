module Portal
  class CampaignsController < BaseController
    before_action :set_campaign

    def show
      @progress = @campaign.progress_percentage
      @items_by_category = @campaign.items_by_category
      @recent_assets = @campaign.campaign_assets.order(created_at: :desc).limit(6)
      @incomplete_items = @campaign.checklist_items.incomplete.order(:position).limit(5)
      @assets_count = @campaign.campaign_assets.count
      @pending_assets = @campaign.campaign_assets.pending.count
      @landing_page = @campaign.landing_page
      @submission_count = @landing_page&.page_submissions&.count || 0
      @current_live_event = @campaign.current_live_event
      @next_event = @campaign.next_scheduled_event
      @upcoming_events = @campaign.live_events.upcoming.limit(3)
      @submission = @campaign.submission
      @confirmations = @campaign.creator_confirmations.index_by(&:section)
      @blockers = @campaign.phase_blockers
      @current_phase_idx = Campaign.phases[@campaign.phase]

      # Content phase data
      @pending_deliverables = @campaign.admin_deliverables.where(status: [:pending_review, :revised]) if @campaign.deliverables_enabled?
      @content_items = @campaign.checklist_items.where(category: 'content').order(:position) if @campaign.asset_uploads_enabled?

      # Review phase data
      @revision_deliverables = @campaign.admin_deliverables.needs_revision if @campaign.deliverables_enabled?
      @all_incomplete = @campaign.checklist_items.required.incomplete.order(:position)

      # Live phase data
      @recent_submissions = @landing_page&.page_submissions&.order(created_at: :desc)&.limit(5) || []
      @personal_video_count = @campaign.personal_videos.count
      @personal_video_total = @landing_page&.page_submissions&.count || 0
      @activities = @campaign.activities.recent.includes(:user).select { |a| a.visible_for_campaign?(@campaign) }.first(30)
    end

    def complete_onboarding
      @campaign.complete_onboarding!
      redirect_to portal_campaign_path(@campaign), notice: "Let's get started!"
    end

    def advance_phase
      if @campaign.can_advance?
        old_phase = @campaign.phase
        @campaign.advance_phase!
        @campaign.skip_empty_phases!
        CampaignActivityLogger.phase_advanced(@campaign, old_phase, @campaign.phase, current_user)
        NotificationService.phase_advanced(@campaign, @campaign.phase)
        redirect_to portal_campaign_path(@campaign), notice: "Advanced to #{@campaign.phase.titleize} phase!"
      else
        redirect_to portal_campaign_path(@campaign), alert: "Cannot advance yet — #{@campaign.phase_blockers.to_sentence}."
      end
    end

    def links
    end

    def update_links
      if @campaign.update(links_params)
        # Auto-update checklist
        if @campaign.signed_editions_url.present?
          @campaign.checklist_items.find_by(key: 'signed_editions_url')&.mark_complete!
        end
        redirect_to links_portal_campaign_path(@campaign), notice: 'Links updated successfully.'
      else
        render :links
      end
    end

    def ad_access
    end

    def update_ad_access
      @campaign.update!(ad_access_params)
      # Auto-update checklist items
      @campaign.checklist_items.find_by(key: 'facebook_access')&.then do |item|
        @campaign.facebook_access? ? item.mark_complete! : item.reset!
      end
      @campaign.checklist_items.find_by(key: 'instagram_access')&.then do |item|
        @campaign.instagram_access? ? item.mark_complete! : item.reset!
      end
      @campaign.checklist_items.find_by(key: 'tiktok_access')&.then do |item|
        @campaign.tiktok_access? ? item.mark_complete! : item.reset!
      end
      redirect_to ad_access_portal_campaign_path(@campaign), notice: 'Ad access updated.'
    end

    def logistics
    end

    def update_logistics
      if @campaign.update(logistics_params)
        # Auto-update checklist
        if @campaign.bookplate_address.present?
          @campaign.checklist_items.find_by(key: 'shipping_address_confirmed')&.mark_complete!
        end
        if @campaign.bookplate_design.present?
          @campaign.checklist_items.find_by(key: 'bookplate_design_uploaded')&.mark_complete!
        end
        if @campaign.management_emails.present?
          @campaign.checklist_items.find_by(key: 'management_contacts_confirmed')&.mark_complete!
        end
        redirect_to logistics_portal_campaign_path(@campaign), notice: 'Logistics info updated.'
      else
        render :logistics
      end
    end

    private

    def set_campaign
      @campaign = current_author.campaigns.find(params[:id])
    end

    def links_params
      params.require(:campaign).permit(:signed_editions_url)
    end

    def ad_access_params
      params.require(:campaign).permit(:facebook_access, :instagram_access, :tiktok_access)
    end

    def logistics_params
      params.require(:campaign).permit(:bookplate_address, :bookplate_design, :management_emails)
    end
  end
end
