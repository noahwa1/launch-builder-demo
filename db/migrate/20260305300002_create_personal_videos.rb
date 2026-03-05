class CreatePersonalVideos < ActiveRecord::Migration[7.2]
  def change
    create_table :personal_videos do |t|
      t.references :campaign,        null: false, foreign_key: true
      t.references :page_submission, null: false, foreign_key: true, index: { unique: true }
      t.string  :file
      t.integer :status, default: 0, null: false
      t.datetime :sent_at

      t.timestamps
    end

    add_index :personal_videos, :status
  end
end
