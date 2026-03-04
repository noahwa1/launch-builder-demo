class CreatePageSubmissions < ActiveRecord::Migration[7.2]
  def change
    create_table :page_submissions do |t|
      t.references :landing_page, null: false, foreign_key: true
      t.string  :form_type
      t.json    :data
      t.string  :receipt
      t.string  :email
      t.string  :ip_address
      t.string  :user_agent
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :page_submissions, :status
    add_index :page_submissions, :email
  end
end
