class Project < ApplicationRecord
  # Associations
  belongs_to :organization, counter_cache: true
  belongs_to :project_manager, class_name: "Membership", optional: true
  has_many :tasks, dependent: :destroy
  has_one_attached :project_logo
  has_many_attached :project_attachments

  # Validations
  validates :name, presence: true, uniqueness: { scope: :organization_id }

  # Callbacks
  after_save :expire_organization_cache
  after_destroy :expire_organization_cache

  # Scopes
  scope :filter_by_active, -> { where(archived: false) }
  scope :filter_by_archived, ->(archived = false) { where(archived: archived) if archived.present? }
  scope :newest_first, -> { order(created_at: :desc) }
  scope :with_task_counts, -> { includes(:tasks).select("projects.*, COUNT(tasks.id) AS tasks_count").left_joins(:tasks).group("projects.id") }
  
  private
  
  def expire_organization_cache
    Rails.cache.delete_matched("organizations/#{organization_id}/*")
    Rails.cache.delete_matched("user_*/organization_#{organization_id}/*")
    Rails.cache.delete_matched("organizations/user_*/all")
    Rails.cache.delete([organization.cache_key_with_version, 'active_projects_count'])
    Rails.cache.delete([organization.cache_key_with_version, 'project_task_counts'])
  end
end
