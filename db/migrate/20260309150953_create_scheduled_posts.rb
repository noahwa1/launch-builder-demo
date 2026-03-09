class CreateScheduledPosts < ActiveRecord::Migration[7.2]
  def change
    create_table :scheduled_posts do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string :platform, null: false
      t.string :category
      t.text :body, null: false
      t.datetime :scheduled_at
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :scheduled_posts, [:campaign_id, :scheduled_at]
    add_index :scheduled_posts, :status
  end
end
