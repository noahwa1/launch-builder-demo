class CreatePortalMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :portal_messages do |t|
      t.integer  :sender_id, null: false
      t.integer  :thread_owner_id, null: false
      t.integer  :submission_id
      t.text     :body, null: false
      t.datetime :read_at
      t.timestamps
    end

    add_index :portal_messages, :sender_id
    add_index :portal_messages, :thread_owner_id
    add_index :portal_messages, :submission_id
  end
end
