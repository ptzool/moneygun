class CreateEmployeeDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :employee_documents do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true

      t.timestamps
    end
  end
end
