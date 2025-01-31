class AddManagarToProject < ActiveRecord::Migration[8.0]
  def change
    add_reference :projects, :project_manager, null: false, foreign_key: { to_table: :memberships }
  end
end
