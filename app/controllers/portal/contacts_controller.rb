module Portal
  class ContactsController < BaseController
    before_action :set_campaign
    before_action :require_fan_crm_enabled
    before_action :set_contact, only: [:show, :update, :add_tag, :remove_tag, :add_note, :enroll_drip]

    def index
      @contacts = @campaign.contacts.includes(:tags).recent
      @contacts = @contacts.where('name LIKE :q OR email LIKE :q', q: "%#{params[:q]}%") if params[:q].present?
      @contacts = @contacts.joins(:tags).where(tags: { id: params[:tag_id] }) if params[:tag_id].present?
      @contacts = @contacts.where(status: params[:status]) if params[:status].present?
      @contacts = @contacts.page(params[:page]).per(50) if @contacts.respond_to?(:page)
      @tags = @campaign.tags.order(:name)
      @total_count = @campaign.contacts.count
      @active_count = @campaign.contacts.active.count
      @top_referrers = @campaign.contacts.joins(:referral_code)
                                .where('referral_codes.referral_count > 0')
                                .order('referral_codes.referral_count DESC')
                                .limit(5)
    end

    def show
      @events = @contact.contact_events.recent.limit(50)
      @tags = @campaign.tags.order(:name)
      @available_drips = @campaign.drip_campaigns.where.not(status: :draft)
      @referral_code = @contact.referral_code
      @referrals = @referral_code&.referrals&.includes(:referred_contact) || []
    end

    def update
      if @contact.update(contact_params)
        redirect_to portal_campaign_contact_path(@campaign, @contact), notice: 'Contact updated.'
      else
        @events = @contact.contact_events.recent.limit(50)
        @tags = @campaign.tags.order(:name)
        render :show
      end
    end

    def add_tag
      tag = @campaign.tags.find_or_create_by!(name: params[:tag_name], color: params[:tag_color] || '#003262')
      @contact.tags << tag unless @contact.tags.include?(tag)
      @contact.record_event!('tagged', subject: tag.name)
      redirect_to portal_campaign_contact_path(@campaign, @contact), notice: "Tagged as #{tag.name}."
    end

    def remove_tag
      tag = Tag.find(params[:tag_id])
      @contact.tags.delete(tag)
      redirect_to portal_campaign_contact_path(@campaign, @contact), notice: "Tag removed."
    end

    def add_note
      @contact.record_event!('manual_note', subject: params[:note_subject], data: { body: params[:note_body] })
      redirect_to portal_campaign_contact_path(@campaign, @contact), notice: 'Note added.'
    end

    def enroll_drip
      drip = @campaign.drip_campaigns.find(params[:drip_campaign_id])
      drip.enroll!(@contact)
      redirect_to portal_campaign_contact_path(@campaign, @contact), notice: "Enrolled in #{drip.name}."
    end

    def import
      if params[:csv].present?
        count = 0
        require 'csv'
        CSV.foreach(params[:csv].path, headers: true) do |row|
          next unless row['email'].present?
          contact = @campaign.contacts.find_or_initialize_by(email: row['email'].strip.downcase)
          contact.name = row['name'] if row['name'].present?
          contact.phone = row['phone'] if row['phone'].present?
          contact.source ||= 'import'
          contact.save && count += 1
        end
        redirect_to portal_campaign_contacts_path(@campaign), notice: "Imported #{count} contacts."
      else
        redirect_to portal_campaign_contacts_path(@campaign), alert: 'Please select a CSV file.'
      end
    end

    private

    def require_fan_crm_enabled
      require_feature!('fan_crm')
    end

    def set_campaign
      @campaign = current_author.campaigns.find(params[:campaign_id])
    end

    def set_contact
      @contact = @campaign.contacts.find(params[:id])
    end

    def contact_params
      params.require(:contact).permit(:name, :email, :phone, :status)
    end
  end
end
