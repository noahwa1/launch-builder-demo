class AddCampaignBuilderFields < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :brief, :text
    add_column :campaigns, :launch_date, :date
    add_column :campaigns, :content_deadline, :date
    add_column :campaigns, :review_deadline, :date
    add_column :campaigns, :ad_access_notes, :text
  end
end
