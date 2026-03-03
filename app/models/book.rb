class Book < ApplicationRecord
  belongs_to :author
  belongs_to :publisher, optional: true
  has_many :royalty_statements
  has_many :royalty_rates

  validates :title, presence: true

  mount_uploader :cover, CoverUploader

  def display_title
    "#{title}#{" (#{isbn})" if isbn.present?}"
  end
end
