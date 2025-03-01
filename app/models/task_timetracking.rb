class TaskTimetracking < ApplicationRecord
  belongs_to :task
  belongs_to :membership

  validates :duration, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def self.total_time_spent_on_task(task_id)
    where(task_id: task_id).sum(:time_spent)
  end

  def self.total_time_spent_by_user(user_id)
    where(membership_id: user_id).sum(:time_spent)
  end
end
