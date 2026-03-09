module Portal
  class ReferralsController < BaseController
    before_action :set_campaign

    def index
      @landing_page = @campaign.landing_page
      @total_referrals = Referral.where(campaign: @campaign).count
      @codes = @campaign.referral_codes
                        .includes(:contact)
                        .order(referral_count: :desc)
                        .limit(50)
      @milestones = [
        { count: 3,  label: 'Bronze',   color: '#CD7F32' },
        { count: 10, label: 'Silver',   color: '#C0C0C0' },
        { count: 25, label: 'Gold',     color: '#FFD700' },
        { count: 50, label: 'Platinum', color: '#E5E4E2' }
      ]
    end

    private

    def set_campaign
      @campaign = current_author.campaigns.find(params[:campaign_id])
    end
  end
end
