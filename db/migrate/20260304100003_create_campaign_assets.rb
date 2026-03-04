class CreateCampaignAssets < ActiveRecord::Migration[7.0]
  def change
    create_table :campaign_assets do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string :asset_type, null: false
      t.string :file
      t.string :original_filename
      t.integer :status, default: 0, null: false
      t.text :admin_notes
      t.integer :reviewed_by
      t.datetime :reviewed_at
      t.timestamps
    end

    add_index :campaign_assets, [:campaign_id, :asset_type]
    add_index :campaign_assets, :status
  end
end
