class CreateRoyaltyStatements < ActiveRecord::Migration[7.0]
  def change
    create_table :royalty_statements do |t|
      t.integer :royalty_payment_id, null: false
      t.integer :book_id, null: false
      t.integer :units_sold, default: 0
      t.decimal :gross_revenue, precision: 10, scale: 2
      t.decimal :royalty_rate, precision: 5, scale: 4
      t.decimal :royalty_amount, precision: 10, scale: 2
      t.timestamps
    end

    add_index :royalty_statements, :royalty_payment_id
    add_index :royalty_statements, :book_id
  end
end
