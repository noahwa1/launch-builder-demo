class CreateCampaignActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :campaign_activities do |t|
      t.references :campaign, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.string :action, null: false
      t.string :subject_type
      t.integer :subject_id
      t.json :metadata, default: {}
      t.timestamps
    end

    add_index :campaign_activities, [:campaign_id, :created_at]
    add_index :campaign_activities, [:subject_type, :subject_id]
  end
end
