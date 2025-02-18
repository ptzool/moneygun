class CreateTaskTimetrackings < ActiveRecord::Migration[8.0]
  def change
    create_table :task_timetrackings do |t|
      t.references :task, null: false, foreign_key: true
      t.references :membership, null: false, foreign_key: true
      t.date :date
      t.time :start
      t.time :end
      t.integer :duration

      t.timestamps
    end
  end
end
