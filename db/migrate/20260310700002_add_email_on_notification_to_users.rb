class AddEmailOnNotificationToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :email_on_notification, :boolean, default: true
  end
end
