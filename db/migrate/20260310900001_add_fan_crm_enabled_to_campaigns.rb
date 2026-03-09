class AddFanCrmEnabledToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :fan_crm_enabled, :boolean, default: true
  end
end
