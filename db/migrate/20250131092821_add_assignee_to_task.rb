class AddAssigneeToTask < ActiveRecord::Migration[8.0]
  def change
    add_reference :tasks, :assignee, null: true, foreign_key: { to_table: :memberships }
  end
end
