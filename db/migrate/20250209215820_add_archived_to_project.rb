class AddArchivedToProject < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :archived, :boolean, derault: false
  end
end
