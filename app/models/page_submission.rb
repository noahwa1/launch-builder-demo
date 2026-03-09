class PageSubmission < ApplicationRecord
  belongs_to :landing_page
  has_one :personal_video

  enum status: { new_submission: 0, reviewed: 1, actioned: 2 }

  mount_uploader :receipt, ReceiptUploader

  validates :form_type, presence: true

  scope :recent, -> { order(created_at: :desc) }

  after_create :sync_to_contact

  private

  def sync_to_contact
    return unless email.present? && landing_page&.campaign.present?
    campaign = landing_page.campaign
    contact = campaign.contacts.find_or_initialize_by(email: email)
    contact.name ||= data&.dig('name') || data&.dig('first_name')
    contact.phone ||= data&.dig('phone')
    contact.source ||= 'page_submission'
    contact.source_id ||= id
    contact.metadata = (contact.metadata || {}).merge('form_type' => form_type)
    contact.save!

    contact.record_event!('receipt_submitted', subject: campaign.title, data: { page_submission_id: id })
    contact.ensure_referral_code!

    # Auto-enroll in active drip campaigns triggered by receipt_submitted
    campaign.drip_campaigns.active.where(trigger_event: 'receipt_submitted').find_each do |drip|
      drip.enroll!(contact)
    end

    # Track referral if ref code present
    if data&.dig('ref').present?
      ref_code = ReferralCode.find_by(code: data['ref'])
      if ref_code && ref_code.contact_id != contact.id
        Referral.find_or_create_by!(referral_code: ref_code, referred_contact: contact, campaign: campaign)
        ref_code.contact.record_event!('referred_friend', subject: contact.display_name)
      end
    end
  end
end
