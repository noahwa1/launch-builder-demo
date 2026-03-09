module Portal
  class ConfirmationsController < BaseController
    before_action :set_campaign

    def create
      section = params[:section]
      unless Campaign::CONFIRMABLE_SECTIONS.include?(section)
        redirect_to portal_campaign_path(@campaign), alert: 'Invalid section.'
        return
      end

      confirmation = @campaign.creator_confirmations.find_or_initialize_by(section: section)
      confirmation.confirmed_by = current_user.id
      confirmation.confirmed_at = Time.current
      confirmation.notes = params[:notes].presence

      if confirmation.save
        if confirmation.has_changes_requested?
          CampaignActivityLogger.section_changes_requested(@campaign, section, current_user, confirmation.notes)
        else
          CampaignActivityLogger.section_confirmed(@campaign, section, current_user)
        end

        # Auto-advance phase if all setup blockers are cleared
        @campaign.skip_empty_phases! if @campaign.setup?

        if confirmation.has_changes_requested?
          redirect_to portal_campaign_path(@campaign), notice: "Change request sent for #{section.titleize}."
        else
          redirect_to portal_campaign_path(@campaign), notice: "#{section.titleize} confirmed."
        end
      else
        redirect_to portal_campaign_path(@campaign), alert: 'Could not save confirmation.'
      end
    end

    private

    def set_campaign
      @campaign = current_author.campaigns.find(params[:campaign_id])
    end
  end
end
