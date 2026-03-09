class AddImageToScheduledPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :scheduled_posts, :image, :string
  end
end
