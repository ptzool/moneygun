class Project < ApplicationRecord
  # Associations
  belongs_to :organization
  belongs_to :project_manager, class_name: "Membership", optional: true
  has_many :tasks
  has_one_attached :project_logo
  has_many_attached :project_attachments

  # Validations
  validates :name, presence: true, uniqueness: { scope: :organization_id }

  # Scopes
  scope :filter_by_active, -> { where(archived: false) }
  scope :filter_by_archived, ->(archived = false) { where(archived: archived) if archived.present? }
  scope :newest_first, -> { order(created_at: :desc) }
end
