class CreateTags < ActiveRecord::Migration[7.0]
  def change
    create_table :tags do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string :name, null: false
      t.string :color, default: '#003262'
      t.timestamps
    end

    add_index :tags, [:campaign_id, :name], unique: true

    create_table :contact_tags do |t|
      t.references :contact, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true
      t.timestamps
    end

    add_index :contact_tags, [:contact_id, :tag_id], unique: true
  end
end
