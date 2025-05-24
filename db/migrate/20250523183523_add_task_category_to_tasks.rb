class AddTaskCategoryToTasks < ActiveRecord::Migration[8.0]
  def change
    add_reference :tasks, :task_category, null: true, foreign_key: true
    add_index :tasks, [ :organization_id, :task_category_id ]
  end
end
