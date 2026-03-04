class CreateLiveEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :live_events do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string  :title, null: false
      t.text    :description
      t.string  :embed_url
      t.string  :stream_platform
      t.integer :status, default: 0, null: false
      t.datetime :scheduled_at
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end

    add_index :live_events, :status
  end
end
