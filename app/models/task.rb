class Task < ApplicationRecord
  belongs_to :organization
  belongs_to :project
  belongs_to :assignee, class_name: "Membership", foreign_key: "assignee_id"
  belongs_to :reporter, class_name: "Membership", foreign_key: "reporter_id"

  enum :status, { open: "open", closed: "closed" }
  enum :priority, { low: "low", medium: "medium", high: "high" }

  has_many :comments, dependent: :destroy
  has_many_attached :task_attachments

  validates :name, presence: true
  validates :project_id, presence: true
  validates :assignee_id, presence: true
  validates :reporter_id, presence: true

  has_paper_trail

  scope :by_priority, ->(priority) { where(priority: priority) if priority.present? }
  scope :by_planned_start_date, ->(planned_start_date) { where("planned_start_date >= ?", planned_start_date) if planned_start_date.present? }
  scope :by_planned_end_date, ->(planned_end_date) { where("planned_end_date >= ?", planned_end_date) if planned_end_date.present? }

  scope :by_status, ->(status = nil) {
    if status.present?
      where(status: status)
    else
      where(status: "open")
    end
  }
end
