class AddCampaignTypeAndFeatureFlags < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :campaign_type, :string, default: 'full'
    add_column :campaigns, :landing_page_enabled, :boolean, default: true
    add_column :campaigns, :asset_uploads_enabled, :boolean, default: true
    add_column :campaigns, :deliverables_enabled, :boolean, default: true
    add_column :campaigns, :live_events_enabled, :boolean, default: true
    add_column :campaigns, :social_tools_enabled, :boolean, default: true
    add_column :campaigns, :royalties_enabled, :boolean, default: true
  end
end
