class TaskTimetracking < ApplicationRecord
  belongs_to :task
  belongs_to :membership

  validates :duration, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
