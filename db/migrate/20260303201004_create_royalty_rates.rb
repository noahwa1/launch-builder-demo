class CreateRoyaltyRates < ActiveRecord::Migration[5.2]
  def change
    create_table :royalty_rates do |t|
      t.integer :author_id, null: false
      t.integer :book_id
      t.decimal :rate, precision: 5, scale: 4, null: false
      t.date    :effective_from, null: false
      t.date    :effective_to
      t.timestamps
    end

    add_index :royalty_rates, :author_id
    add_index :royalty_rates, :book_id
  end
end
