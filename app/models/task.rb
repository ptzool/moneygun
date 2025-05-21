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
  enum :status, { open: "open", in_progress: "in_progress", closed: "closed" }
  enum :priority, { low: "low", medium: "medium", high: "high" }

  # Validations
  validates :name, :project_id, :assignee_id, :reporter_id, presence: true

  # Version control
  has_paper_trail

  # Scopes
  scope :filter_by_priority, ->(priority) { where(priority: priority) if priority.present? }
  scope :filter_by_planned_start_date, ->(date) { where("planned_start_date >= ?", date) if date.present? }
  scope :filter_by_planned_end_date, ->(date) { where("planned_end_date >= ?", date) if date.present? }
  scope :filter_by_status, ->(status = nil) { status.present? ? where(status: status) : where(status: [ "open", "in_progress" ]) }
  scope :from_active_projects, -> {
    # Használunk includes-t a joins helyett, hogy elkerüljük az N+1 problémát
    # Csak akkor használjuk az includes-t, ha valóban szükség van a project adataira
    joins(:project).where(projects: { archived: false })
  }

  scope :search_by_name, ->(query) {
    where("tasks.name ILIKE ?", "%#{query}%") if query.present?
  }

  scope :with_projects, -> {
    # Ez a scope betölti a kapcsolódó projekteket (amikor a nézet megjeleníti a projekt adatait)
    includes(:project)
  }
  scope :newest_first, -> { order(created_at: :desc) }

  # Kombinált scope-ok a gyakori lekérdezésekre
  # - Csak a szükséges includes-okat használjuk, hogy elkerüljük a felesleges adatbetöltést
  scope :active_tasks, -> { where(status: [ "open", "in_progress" ]) }
  scope :with_associations, -> { includes(:project, :assignee, :reporter) }
  scope :recent_active_tasks, -> { active_tasks.newest_first.limit(50) }

  # Optimalizált scope a dashboard-hoz és API-hoz
  scope :for_listing, -> { select(:id, :name, :status, :priority, :project_id, :assignee_id, :reporter_id, :planned_start_date, :planned_end_date) }


  def total_time_spent
    if task_timetrackings_count == 0
      return 0
    end

    task_timetrackings.sum(:duration)
  end

  # Returns total time spent in hours
  def total_time_spent_in_hours
    (total_time_spent.to_f / 60.0).round(1)
  end

  def total_time_spent_by_users
    task_timetrackings.group(:membership_id).sum(:duration)
  end

  # Returns total time spent by users in hours
  def total_time_spent_by_users_in_hours
    total_time_spent_by_users.transform_values { |minutes| (minutes.to_f / 60.0).round(1) }
  end
end
