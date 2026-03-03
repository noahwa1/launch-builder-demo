class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  enum role: { creator: 0, admin: 1 }

  belongs_to :account, polymorphic: true, optional: true

  has_many :submissions, foreign_key: :submitted_by
  has_many :sent_messages, class_name: 'PortalMessage', foreign_key: :sender_id

  def full_name
    [first_name, last_name].compact.join(' ').presence || email
  end

  def initials
    if first_name.present? && last_name.present?
      "#{first_name[0]}#{last_name[0]}".upcase
    else
      email[0..1].upcase
    end
  end

  def author
    account if account_type == 'Author'
  end
end
