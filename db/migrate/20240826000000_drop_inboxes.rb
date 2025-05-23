class DropInboxes < ActiveRecord::Migration[7.1]
  def up
    drop_table :inboxes
  end

  def down
    create_table :inboxes do |t|
      t.string :name, null: false
      t.references :organization, null: false, foreign_key: true

      t.timestamps
      t.index [:name, :organization_id], unique: true
    end
  end
end