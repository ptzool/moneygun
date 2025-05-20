class ProjectMember < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validates :project, presence: true
  validates :user, presence: true
  validates :role, presence: true, inclusion: { in: %w[owner member viewer] }
  validates :user_id, uniqueness: { scope: :project_id, message: "is already a member of this project" }

  scope :owners, -> { where(role: 'owner') }
  scope :members, -> { where(role: 'member') }
  scope :viewers, -> { where(role: 'viewer') }
end