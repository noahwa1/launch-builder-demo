class CreateAuthors < ActiveRecord::Migration[5.2]
  def change
    create_table :authors do |t|
      t.string :first_name
      t.string :last_name
      t.string :full_name
      t.text   :description
      t.string :image
      t.integer :status, default: 0, null: false
      t.timestamps
    end
  end
end
