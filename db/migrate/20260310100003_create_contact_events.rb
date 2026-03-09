class CreateContactEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :contact_events do |t|
      t.references :contact, null: false, foreign_key: true
      t.string :event_type, null: false  # receipt_submitted, email_sent, email_opened, email_clicked, referred_friend, video_received, tagged
      t.string :subject                  # e.g. email subject, tag name, drip step name
      t.json :data                       # flexible event details
      t.timestamps
    end

    add_index :contact_events, :event_type
    add_index :contact_events, :created_at
  end
end
