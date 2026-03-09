class DeliverableNote < ApplicationRecord
  belongs_to :admin_deliverable
  belongs_to :user

  validates :body, presence: true

  scope :recent, -> { order(created_at: :asc) }
end
