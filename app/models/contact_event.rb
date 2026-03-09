class ContactEvent < ApplicationRecord
  belongs_to :contact

  validates :event_type, presence: true

  scope :recent, -> { order(created_at: :desc) }

  EVENT_TYPES = %w[
    receipt_submitted email_sent email_opened email_clicked
    referred_friend video_received tagged manual_note
  ].freeze

  def icon
    case event_type
    when 'receipt_submitted' then 'receipt'
    when 'email_sent'        then 'mail'
    when 'email_opened'      then 'mail-open'
    when 'email_clicked'     then 'mouse-pointer'
    when 'referred_friend'   then 'share-2'
    when 'video_received'    then 'video'
    when 'tagged'            then 'tag'
    when 'manual_note'       then 'edit-3'
    else 'activity'
    end
  end
end
