class TaskTimetracking < ApplicationRecord
  belongs_to :task
  belongs_to :membership
end
