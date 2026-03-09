class DripEnrollment < ApplicationRecord
  belongs_to :drip_campaign
  belongs_to :contact
  has_many :drip_messages, dependent: :destroy

  enum status: { active: 0, completed: 1, cancelled: 2 }

  validates :contact_id, uniqueness: { scope: :drip_campaign_id }

  scope :due, -> { active.where('next_send_at <= ?', Time.current) }

  def advance!
    steps = drip_campaign.drip_steps.to_a
    next_pos = current_step + 1

    if next_pos >= steps.size
      update!(status: :completed, completed_at: Time.current, next_send_at: nil)
    else
      next_step = steps[next_pos]
      update!(current_step: next_pos, next_send_at: next_step.delay_hours.hours.from_now)
    end
  end

  def current_drip_step
    drip_campaign.drip_steps.find_by(position: current_step)
  end
end
