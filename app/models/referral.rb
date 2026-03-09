class Referral < ApplicationRecord
  belongs_to :referral_code, counter_cache: :referral_count
  belongs_to :referred_contact, class_name: 'Contact'
  belongs_to :campaign

  validates :referred_contact_id, uniqueness: { scope: :referral_code_id }
end
