class CreatePublishers < ActiveRecord::Migration[7.0]
  def change
    create_table :publishers do |t|
      t.string :name, null: false
      t.string :label
      t.timestamps
    end
  end
end
