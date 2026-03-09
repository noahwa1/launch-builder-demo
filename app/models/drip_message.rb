class DripMessage < ApplicationRecord
  belongs_to :drip_enrollment
  belongs_to :drip_step
  belongs_to :contact

  enum status: { sent: 0, delivered: 1, opened: 2, clicked: 3, bounced: 4 }
end
