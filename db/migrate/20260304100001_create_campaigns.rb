class CreateCampaigns < ActiveRecord::Migration[7.0]
  def change
    create_table :campaigns do |t|
      t.references :submission, null: false, foreign_key: true, index: { unique: true }
      t.references :author, null: false, foreign_key: true
      t.references :book, foreign_key: true
      t.string :title, null: false
      t.integer :status, default: 0, null: false
      t.string :signed_editions_url
      t.text :bookplate_address
      t.string :bookplate_design
      t.string :management_emails
      t.boolean :facebook_access, default: false
      t.boolean :instagram_access, default: false
      t.boolean :tiktok_access, default: false
      t.timestamps
    end

    add_index :campaigns, :status
  end
end
