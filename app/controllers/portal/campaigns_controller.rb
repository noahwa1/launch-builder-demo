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
