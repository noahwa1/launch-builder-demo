class DripCampaign < ApplicationRecord
  belongs_to :campaign
  has_many :drip_steps, -> { order(:position) }, dependent: :destroy
  has_many :drip_enrollments, dependent: :destroy
  has_many :drip_messages, through: :drip_enrollments

  enum status: { draft: 0, active: 1, paused: 2 }

  validates :name, presence: true

  TRIGGER_EVENTS = {
    'receipt_submitted' => 'Receipt Submitted',
    'manual'            => 'Manually Enrolled',
    'referral'          => 'Referred by Friend',
    'tagged'            => 'Tag Added'
  }.freeze

  def enroll!(contact)
    return if drip_enrollments.exists?(contact: contact)
    enrollment = drip_enrollments.create!(contact: contact, current_step: 0)
    first_step = drip_steps.first
    if first_step
      enrollment.update!(next_send_at: first_step.delay_hours.hours.from_now)
    end
    enrollment
  end

  def enrolled_count
    drip_enrollments.count
  end

  def completed_count
    drip_enrollments.where(status: :completed).count
  end
end
