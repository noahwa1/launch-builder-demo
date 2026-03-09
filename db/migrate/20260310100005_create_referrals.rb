class CreateReferrals < ActiveRecord::Migration[7.0]
  def change
    create_table :referral_codes do |t|
      t.references :contact, null: false, foreign_key: true
      t.references :campaign, null: false, foreign_key: true
      t.string :code, null: false
      t.integer :referral_count, default: 0
      t.timestamps
    end

    add_index :referral_codes, :code, unique: true

    create_table :referrals do |t|
      t.references :referral_code, null: false, foreign_key: true
      t.references :referred_contact, null: false, foreign_key: { to_table: :contacts }
      t.references :campaign, null: false, foreign_key: true
      t.timestamps
    end

    add_index :referrals, [:referral_code_id, :referred_contact_id], unique: true
  end
end
