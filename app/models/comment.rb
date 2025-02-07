class Comment < ApplicationRecord
  belongs_to :membership
  belongs_to :task

  validates :body, presence: true
end
