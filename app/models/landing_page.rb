class LandingPage < ApplicationRecord
  belongs_to :campaign, optional: true
  belongs_to :author, optional: true
  has_many :page_submissions, dependent: :destroy

  validates :slug, uniqueness: true, allow_nil: true
  validates :slug, format: { with: /\A[a-z0-9][a-z0-9\-]{1,98}[a-z0-9]\z/, message: 'must be 3-100 characters, letters/numbers/hyphens only' }, allow_blank: true

  before_validation :generate_slug, if: -> { slug.blank? && title.present? }
  before_validation :normalize_slug, if: -> { slug.present? && slug_changed? }

  def publish!
    update!(published: true, published_at: Time.current)
    campaign&.checklist_items&.find_by(key: 'landing_page_built')&.mark_complete!
  end

  def unpublish!
    update!(published: false, published_at: nil)
  end

  def request_build!
    update!(build_requested: true, build_requested_at: Time.current)
  end

  def has_content?
    html_content.present?
  end

  private

  def normalize_slug
    self.slug = slug.downcase.parameterize
  end

  def generate_slug
    base = title.parameterize
    candidate = base
    counter = 1
    while LandingPage.where.not(id: id).exists?(slug: candidate)
      candidate = "#{base}-#{counter}"
      counter += 1
    end
    self.slug = candidate
  end
end
