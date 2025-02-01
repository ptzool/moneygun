class AddFieldsToTask < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :status, :string, null: true, default: 'open'
  end
end
