class Contact < ApplicationRecord
  belongs_to :campaign
  has_many :contact_tags, dependent: :destroy
  has_many :tags, through: :contact_tags
  has_many :contact_events, dependent: :destroy
  has_many :drip_enrollments, dependent: :destroy
  has_many :drip_messages, dependent: :destroy
  has_one :referral_code, dependent: :destroy

  enum status: { active: 0, unsubscribed: 1, bounced: 2 }

  validates :email, presence: true, uniqueness: { scope: :campaign_id }

  scope :recent, -> { order(created_at: :desc) }
  scope :engaged, -> { where('score >= ?', 10).order(score: :desc) }
  scope :with_activity, -> { where.not(last_activity_at: nil).order(last_activity_at: :desc) }

  def display_name
    name.presence || email.split('@').first
  end

  def record_event!(event_type, subject: nil, data: nil)
    contact_events.create!(event_type: event_type, subject: subject, data: data)
    increment!(:score, score_for(event_type))
    touch(:last_activity_at)
  end

  def ensure_referral_code!
    referral_code || create_referral_code!(campaign: campaign, code: generate_unique_code)
  end

  private

  def score_for(event_type)
    case event_type
    when 'receipt_submitted' then 10
    when 'email_opened'      then 2
    when 'email_clicked'     then 5
    when 'referred_friend'   then 15
    when 'video_received'    then 8
    else 1
    end
  end

  def generate_unique_code
    loop do
      code = SecureRandom.alphanumeric(8).upcase
      return code unless ReferralCode.exists?(code: code)
    end
  end
end
