class AddIndexesToTasks < ActiveRecord::Migration[8.0]
  def change
    add_index :tasks, :status
    add_index :tasks, :priority
    add_index :tasks, :planned_start_date
    add_index :tasks, :planned_end_date
    add_index :tasks, [:organization_id, :status]
    add_index :tasks, [:organization_id, :priority]
    add_index :tasks, [:project_id, :status]
    add_index :tasks, [:assignee_id, :status]
  end
end