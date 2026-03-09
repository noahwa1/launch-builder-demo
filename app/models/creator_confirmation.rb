class CreatorConfirmation < ApplicationRecord
  belongs_to :campaign
  belongs_to :confirmer, class_name: 'User', foreign_key: :confirmed_by

  validates :section, presence: true, uniqueness: { scope: :campaign_id }
  validates :section, inclusion: { in: %w[links ad_access logistics brief] }

  after_create :complete_related_checklist_items

  def has_changes_requested?
    notes.present?
  end

  private

  def complete_related_checklist_items
    return if has_changes_requested?
    campaign.checklist_items.where(category: section).each(&:mark_complete!)
  end
end
