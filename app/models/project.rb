class Project < ApplicationRecord
  belongs_to :organization
  belongs_to :project_manager, class_name: "Membership", optional: true

  has_many :tasks
  scope :active, -> { where(archived: false) }
  scope :by_archived, ->(archived = false) { where(archived: archived) if archived.present? }

  has_one_attached :project_logo

  validates :name, presence: true, uniqueness: { scope: :organization_id }
end
