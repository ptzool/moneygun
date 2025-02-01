class Task < ApplicationRecord
  belongs_to :organization
  belongs_to :project
  belongs_to :assignee, class_name: "Membership", optional: true
  belongs_to :reporter, class_name: "Membership", optional: true


  enum :status, { open: "open", closed: "closed" }
  enum :priority, { low: "low", medium: "medium", high: "high" }

  has_many :comments, dependent: :destroy
  has_many_attached :task_attachments

  has_paper_trail
end
