class Project < ApplicationRecord
  belongs_to :organization
  belongs_to :project_manager, class_name: "Membership", optional: true

  has_many :tasks
  has_one_attached :project_logo

  validates :name, presence: true, uniqueness: { scope: :organization_id }
end
