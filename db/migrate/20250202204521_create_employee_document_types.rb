class CreateEmployeeDocumentTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :employee_document_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
