class Author < ApplicationRecord
  enum status: { active: 0, inactive: 1 }

  has_many :books
  has_many :submissions
  has_many :campaigns
  has_many :royalty_rates
  has_many :royalty_payments
  has_one  :user, as: :account

  validates :first_name, presence: true
  validates :last_name, presence: true

  before_save :set_full_name

  private

  def set_full_name
    self.full_name = "#{first_name} #{last_name}"
  end
end
