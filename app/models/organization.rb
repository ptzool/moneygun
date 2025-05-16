class Organization < ApplicationRecord
  # Associations
  has_many :memberships, dependent: :destroy, counter_cache: true
  has_many :users, through: :memberships
  belongs_to :owner, class_name: "User"

  include Transfer

  has_many :inboxes, dependent: :destroy
  has_many :projects, dependent: :destroy, counter_cache: true
  has_many :tasks, dependent: :destroy, counter_cache: true

  # Validations
  validates :name, presence: true

  # Attachments
  has_one_attached :logo

  # Callbacks
  after_save :expire_organization_cache
  after_destroy :expire_organization_cache
  after_commit :invalidate_organizations_cache, on: [:create]

  # Scopes
  scope :with_counts, -> { select('organizations.*, COUNT(DISTINCT projects.id) as projects_count, COUNT(DISTINCT memberships.id) as members_count')
                            .left_joins(:projects, :memberships)
                            .group('organizations.id') }
  
  scope :active_projects, -> { 
    projects.where(archived: false) 
  }
  
  scope :with_associations, -> { 
    includes(projects: {project_manager: :user}, 
            memberships: :user, 
            tasks: [:project, :assignee, :reporter]) 
  }

  scope :newest_first, -> { order(created_at: :desc) }

  # Instance methods
  def active_projects_count
    Rails.cache.fetch([cache_key_with_version, 'active_projects_count']) do
      projects.where(archived: false).count
    end
  end

  def recent_tasks(limit = 5)
    Rails.cache.fetch([cache_key_with_version, 'recent_tasks', limit]) do
      tasks.includes(:project, :assignee, :reporter)
           .order(created_at: :desc)
           .limit(limit)
    end
  end

  def project_task_counts
    Rails.cache.fetch([cache_key_with_version, 'project_task_counts']) do
      projects.includes(:tasks)
              .where(archived: false)
              .map { |p| [p.id, p.tasks.size] }
              .to_h
    end
  end

  private

  def expire_organization_cache
    # Clear specific organization caches
    Rails.cache.delete_matched("organizations/#{id}/*")
    Rails.cache.delete_matched("user_*/organization_#{id}/*")
    Rails.cache.delete([cache_key_with_version, 'active_projects_count'])
    Rails.cache.delete([cache_key_with_version, 'recent_tasks', 5])
    Rails.cache.delete([cache_key_with_version, 'project_task_counts'])
  end
  
  def invalidate_organizations_cache
    # Clear the organization listing cache when a new organization is created
    Rails.cache.delete_matched("organizations/user_*/all")
  end
end
