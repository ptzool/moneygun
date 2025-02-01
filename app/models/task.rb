class Task < ApplicationRecord
  belongs_to :organization
  belongs_to :project
  belongs_to :assignee, class_name: "Membership", foreign_key: 'assignee_id'
  belongs_to :reporter, class_name: "Membership", foreign_key: 'reporter_id'

  enum :status, { open: "open", closed: "closed" }
  enum :priority, { low: "low", medium: "medium", high: "high" }

  has_many :comments, dependent: :destroy
  has_many_attached :task_attachments

  validates :name, presence: true
  validates :project_id, presence: true
  validates :assignee_id, presence: true
  validates :reporter_id, presence: true

  has_paper_trail
end
