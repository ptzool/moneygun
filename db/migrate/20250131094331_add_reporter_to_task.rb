class AddReporterToTask < ActiveRecord::Migration[8.0]
  def change
    add_reference :tasks, :reporter, null: false, foreign_key: { to_table: :memberships }
  end
end
