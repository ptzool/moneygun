class AddFieldsToTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :priority, :integer
    add_column :tasks, :planned_start_date, :date
    add_column :tasks, :planned_end_date, :date
  end
end
