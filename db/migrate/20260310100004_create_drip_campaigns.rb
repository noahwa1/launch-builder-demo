class CreateDripCampaigns < ActiveRecord::Migration[7.0]
  def change
    create_table :drip_campaigns do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string :name, null: false
      t.string :trigger_event, default: 'receipt_submitted'  # what enrolls contacts
      t.integer :status, default: 0  # draft, active, paused
      t.timestamps
    end

    create_table :drip_steps do |t|
      t.references :drip_campaign, null: false, foreign_key: true
      t.integer :position, default: 0
      t.integer :delay_hours, default: 0     # hours after previous step (or enrollment)
      t.string :channel, default: 'email'    # email, sms
      t.string :subject                      # email subject
      t.text :body, null: false              # message body (supports {{name}}, {{book_title}}, etc.)
      t.timestamps
    end

    add_index :drip_steps, [:drip_campaign_id, :position]

    create_table :drip_enrollments do |t|
      t.references :drip_campaign, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.integer :current_step, default: 0
      t.integer :status, default: 0  # active, completed, cancelled
      t.datetime :next_send_at
      t.datetime :completed_at
      t.timestamps
    end

    add_index :drip_enrollments, [:drip_campaign_id, :contact_id], unique: true
    add_index :drip_enrollments, :next_send_at

    create_table :drip_messages do |t|
      t.references :drip_enrollment, null: false, foreign_key: true
      t.references :drip_step, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.integer :status, default: 0  # sent, delivered, opened, clicked, bounced
      t.datetime :sent_at
      t.datetime :opened_at
      t.datetime :clicked_at
      t.timestamps
    end
  end
end
