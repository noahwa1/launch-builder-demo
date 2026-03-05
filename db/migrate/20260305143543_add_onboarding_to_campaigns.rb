class AddOnboardingToCampaigns < ActiveRecord::Migration[7.2]
  def change
    add_column :campaigns, :onboarding_completed_at, :datetime
    add_column :campaigns, :example_category, :string
  end
end
