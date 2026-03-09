class Tag < ApplicationRecord
  belongs_to :campaign
  has_many :contact_tags, dependent: :destroy
  has_many :contacts, through: :contact_tags

  validates :name, presence: true, uniqueness: { scope: :campaign_id }

  TAG_COLORS = %w[#003262 #E1306C #1DA1F2 #16A34A #F59E0B #8B5CF6 #EF4444 #06B6D4 #F97316 #6366F1].freeze
end
