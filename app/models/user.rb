class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  enum role: { creator: 0, admin: 1 }

  belongs_to :account, polymorphic: true, optional: true

  after_create :create_author_profile!, if: :creator?

  scope :active_users, -> { where(active: true) }

  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : :account_disabled
  end

  private

  def create_author_profile!
    return if account.present?
    name_parts = (full_name.presence || email.split('@').first).split(' ', 2)
    author = Author.create!(
      first_name: name_parts.first,
      last_name: name_parts.last,
      status: :active
    )
    update!(account: author)
  end

  public

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
