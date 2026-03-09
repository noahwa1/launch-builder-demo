class CreateAdminDeliverables < ActiveRecord::Migration[7.0]
  def change
    create_table :admin_deliverables do |t|
      t.references :campaign, null: false, foreign_key: true
      t.integer :created_by, null: false
      t.string :title, null: false
      t.text :description
      t.string :category, null: false
      t.string :file
      t.integer :status, default: 0
      t.text :creator_notes
      t.integer :revision_count, default: 0
      t.date :due_date
      t.timestamps
    end

    add_index :admin_deliverables, :status
    add_index :admin_deliverables, :created_by

    create_table :deliverable_notes do |t|
      t.references :admin_deliverable, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.timestamps
    end
  end
end
