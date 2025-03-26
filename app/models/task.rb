class Task < ApplicationRecord
  # Associations
  belongs_to :organization
  belongs_to :project
  belongs_to :assignee, class_name: "Membership"
  belongs_to :reporter, class_name: "Membership"
  has_many :comments, dependent: :destroy
  has_many :task_timetrackings, dependent: :destroy
  has_many_attached :task_attachments

  # Enums
  enum :status, { open: "open", closed: "closed" }
  enum :priority, { low: "low", medium: "medium", high: "high" }

  # Validations
  validates :name, :project_id, :assignee_id, :reporter_id, presence: true

  # Version control
  has_paper_trail

  # Scopes
  scope :filter_by_priority, ->(priority) { where(priority: priority) if priority.present? }
  scope :filter_by_planned_start_date, ->(date) { where("planned_start_date >= ?", date) if date.present? }
  scope :filter_by_planned_end_date, ->(date) { where("planned_end_date >= ?", date) if date.present? }
  scope :filter_by_status, ->(status = nil) { status.present? ? where(status: status) : where(status: "open") }
  scope :from_active_projects, -> { joins(:project).merge(Project.filter_by_active) }
  scope :newest_first, -> { order(created_at: :desc) }


  def total_time_spent
    task_timetrackings.sum(:duration)
  end

  def total_time_spent_by_users
    task_timetrackings.group(:membership_id).sum(:duration)
  end
end
