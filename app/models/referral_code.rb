class ReferralCode < ApplicationRecord
  belongs_to :contact
  belongs_to :campaign
  has_many :referrals, dependent: :destroy

  validates :code, presence: true, uniqueness: true

  def referral_url(base_url)
    "#{base_url}?ref=#{code}"
  end

  def milestone_reached?(threshold)
    referral_count >= threshold
  end
end
