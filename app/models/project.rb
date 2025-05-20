class Project < ApplicationRecord
  # Associations
  belongs_to :organization, counter_cache: true
  belongs_to :project_manager, class_name: "Membership", optional: true
  has_many :tasks, dependent: :destroy
  has_many :project_members, dependent: :destroy
  has_many :members, through: :project_members, source: :user
  has_one_attached :project_logo

  # Safe variant access methods to avoid processing errors
  def project_logo_thumb
    project_logo.representation(resize_to_limit: [ 40, 40 ]) if project_logo.attached?
  end

  def project_logo_icon
    project_logo.representation(resize_to_limit: [ 24, 24 ]) if project_logo.attached?
  end

  def project_logo_medium
    project_logo.representation(resize_to_limit: [ 64, 64 ]) if project_logo.attached?
  end
  has_many_attached :project_attachments

  # Validations
  validates :name, presence: true, uniqueness: { scope: :organization_id }

  # Scopes
  scope :filter_by_active, -> { where(archived: false) }
  scope :filter_by_archived, ->(archived = false) { where(archived: archived) if archived.present? }
  scope :newest_first, -> { order(created_at: :desc) }
  scope :with_task_counts, -> { includes(:tasks).select("projects.*, COUNT(tasks.id) AS tasks_count").left_joins(:tasks).group("projects.id") }
end
