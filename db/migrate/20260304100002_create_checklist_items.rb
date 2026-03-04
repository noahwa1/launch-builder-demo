class CreateChecklistItems < ActiveRecord::Migration[7.0]
  def change
    create_table :checklist_items do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :category, null: false
      t.integer :status, default: 0, null: false
      t.integer :position, default: 0
      t.boolean :optional, default: false
      t.string :key
      t.datetime :completed_at
      t.timestamps
    end

    add_index :checklist_items, [:campaign_id, :key], unique: true
    add_index :checklist_items, [:campaign_id, :category]
  end
end
