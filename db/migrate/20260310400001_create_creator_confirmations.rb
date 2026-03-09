class CreateCreatorConfirmations < ActiveRecord::Migration[7.0]
  def change
    create_table :creator_confirmations do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string :section, null: false
      t.integer :confirmed_by, null: false
      t.datetime :confirmed_at, null: false
      t.text :notes

      t.timestamps
    end

    add_index :creator_confirmations, [:campaign_id, :section], unique: true
  end
end
