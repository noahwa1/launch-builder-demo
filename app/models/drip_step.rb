class DripStep < ApplicationRecord
  belongs_to :drip_campaign
  has_many :drip_messages, dependent: :destroy

  validates :body, presence: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }

  def delay_label
    if delay_hours == 0
      'Immediately'
    elsif delay_hours < 24
      "#{delay_hours} hour#{'s' if delay_hours != 1} later"
    else
      days = delay_hours / 24
      "#{days} day#{'s' if days != 1} later"
    end
  end

  def render_body(contact)
    text = body.dup
    text.gsub!('{{name}}', contact.display_name)
    text.gsub!('{{email}}', contact.email || '')
    text.gsub!('{{book_title}}', drip_campaign.campaign.title || '')
    if contact.referral_code
      text.gsub!('{{referral_link}}', contact.referral_code.code)
    end
    text
  end
end
