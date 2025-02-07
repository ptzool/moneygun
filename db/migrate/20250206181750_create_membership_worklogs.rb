class CreateMembershipWorklogs < ActiveRecord::Migration[8.0]
  def change
    create_table :membership_worklogs do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :membership, null: false, foreign_key: true
      t.date :date
      t.time :check_in
      t.time :check_out

      t.timestamps
    end
  end
end
