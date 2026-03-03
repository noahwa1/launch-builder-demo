class CreateSubmissions < ActiveRecord::Migration[7.0]
  def change
    create_table :submissions do |t|
      t.integer  :author_id, null: false
      t.integer  :submitted_by, null: false
      t.string   :title, null: false
      t.string   :isbn
      t.text     :description
      t.string   :cover
      t.date     :release_date
      t.string   :genre
      t.integer  :status, default: 0, null: false
      t.text     :admin_notes
      t.integer  :reviewed_by
      t.datetime :submitted_at
      t.datetime :reviewed_at
      t.timestamps
    end

    add_index :submissions, :author_id
    add_index :submissions, :submitted_by
    add_index :submissions, :isbn, unique: true
    add_index :submissions, :status
  end
end
