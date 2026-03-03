class CreateBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :books do |t|
      t.string  :title, null: false
      t.string  :isbn
      t.text    :description
      t.string  :cover
      t.date    :release_date
      t.integer :author_id, null: false
      t.integer :publisher_id
      t.timestamps
    end

    add_index :books, :author_id
    add_index :books, :publisher_id
    add_index :books, :isbn, unique: true
  end
end
