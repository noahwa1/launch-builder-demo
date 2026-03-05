class AddPersonalVideosEnabledToCampaigns < ActiveRecord::Migration[7.2]
  def change
    add_column :campaigns, :personal_videos_enabled, :boolean, default: false
  end
end
