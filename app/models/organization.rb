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

  # Safe variant access methods to avoid processing errors
  def logo_thumb
    logo.representation(resize_to_limit: [ 150, 150 ]) if logo.attached?
  end

  def logo_icon
    logo.representation(resize_to_limit: [ 40, 40 ]) if logo.attached?
  end

  def logo_medium
    logo.representation(resize_to_limit: [ 300, 300 ]) if logo.attached?
  end

  scope :active_projects, -> {
    projects.where(archived: false)
  }

  scope :with_associations, -> {
    includes(projects: { project_manager: :user },
            memberships: :user,
            tasks: [ :project, :assignee, :reporter ])
  }

  scope :newest_first, -> { order(created_at: :desc) }
end
