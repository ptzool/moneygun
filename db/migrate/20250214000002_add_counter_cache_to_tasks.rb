class AddCounterCacheToTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :tasks_count, :integer, default: 0, null: false
    add_column :tasks, :comments_count, :integer, default: 0, null: false
    add_column :tasks, :task_timetrackings_count, :integer, default: 0, null: false
    
    # Update existing counts
    reversible do |dir|
      dir.up do
        # Set counter values for existing records
        execute <<-SQL
          UPDATE projects
          SET tasks_count = (
            SELECT COUNT(id)
            FROM tasks
            WHERE tasks.project_id = projects.id
          )
        SQL
        
        execute <<-SQL
          UPDATE tasks
          SET comments_count = (
            SELECT COUNT(id)
            FROM comments
            WHERE comments.task_id = tasks.id
          )
        SQL
        
        execute <<-SQL
          UPDATE tasks
          SET task_timetrackings_count = (
            SELECT COUNT(id)
            FROM task_timetrackings
            WHERE task_timetrackings.task_id = tasks.id
          )
        SQL
      end
    end
  end
end