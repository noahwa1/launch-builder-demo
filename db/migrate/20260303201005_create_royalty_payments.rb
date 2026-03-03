class CreateRoyaltyPayments < ActiveRecord::Migration[7.0]
  def change
    create_table :royalty_payments do |t|
      t.integer  :author_id, null: false
      t.decimal  :amount, precision: 10, scale: 2, null: false
      t.string   :currency, default: 'USD'
      t.integer  :status, default: 0, null: false
      t.date     :period_start, null: false
      t.date     :period_end, null: false
      t.string   :reference
      t.text     :notes
      t.datetime :paid_at
      t.timestamps
    end

    add_index :royalty_payments, :author_id
    add_index :royalty_payments, :status
  end
end
