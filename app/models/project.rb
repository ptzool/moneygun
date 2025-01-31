class Project < ApplicationRecord
  belongs_to :organization
  belongs_to :project_manager, class_name: "Membership", optional: true

  has_many :tasks
  validates :name, presence: true, uniqueness: { scope: :organization_id }
end
