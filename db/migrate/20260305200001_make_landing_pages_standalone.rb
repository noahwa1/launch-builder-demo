class MakeLandingPagesStandalone < ActiveRecord::Migration[7.0]
  def change
    change_column_null :landing_pages, :campaign_id, true
    add_column :landing_pages, :author_id, :integer
    add_index :landing_pages, :author_id

    remove_foreign_key :landing_pages, :campaigns
    add_foreign_key :landing_pages, :campaigns, on_delete: :nullify
  end
end
