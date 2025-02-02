class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :membership, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
