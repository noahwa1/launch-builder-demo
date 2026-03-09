class MakeContentChecklistItemsOptional < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      UPDATE checklist_items SET optional = 1 WHERE category = 'content'
    SQL
  end

  def down
    execute <<-SQL
      UPDATE checklist_items SET optional = 0 WHERE category = 'content'
    SQL
  end
end
