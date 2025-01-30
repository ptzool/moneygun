class Comment < ApplicationRecord
  belongs_to :membership
  belongs_to :task
end
