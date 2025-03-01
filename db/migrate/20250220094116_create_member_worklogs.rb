class CreateMemberWorklogs < ActiveRecord::Migration[8.0]
  def change
    create_table :member_worklogs do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :membership, null: false, foreign_key: true
      t.date :date
      t.string :type

      t.timestamps
    end
  end
end
