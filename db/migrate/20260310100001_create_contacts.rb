class CreateContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :contacts do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string :email
      t.string :name
      t.string :phone
      t.string :source         # page_submission, manual, referral, import
      t.integer :source_id     # optional FK to page_submission
      t.json :metadata         # flexible extra data
      t.integer :score, default: 0   # engagement score
      t.integer :status, default: 0  # active, unsubscribed, bounced
      t.datetime :last_activity_at
      t.timestamps
    end

    add_index :contacts, [:campaign_id, :email], unique: true
    add_index :contacts, :score
    add_index :contacts, :status
  end
end
