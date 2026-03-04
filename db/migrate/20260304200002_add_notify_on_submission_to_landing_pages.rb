class AddNotifyOnSubmissionToLandingPages < ActiveRecord::Migration[7.2]
  def change
    add_column :landing_pages, :notify_on_submission, :boolean, default: true
  end
end
