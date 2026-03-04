class CreateLandingPages < ActiveRecord::Migration[7.0]
  def change
    create_table :landing_pages do |t|
      t.references :campaign, null: false, foreign_key: true, index: { unique: true }
      t.string :title
      t.text :html_content
      t.text :css_content
      t.boolean :published, default: false
      t.string :slug
      t.datetime :published_at
      t.timestamps
    end

    add_index :landing_pages, :slug, unique: true
  end
end
