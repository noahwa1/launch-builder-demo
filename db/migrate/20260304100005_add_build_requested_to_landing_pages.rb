class AddBuildRequestedToLandingPages < ActiveRecord::Migration[7.0]
  def change
    add_column :landing_pages, :build_requested, :boolean, default: false
    add_column :landing_pages, :build_requested_at, :datetime
  end
end
