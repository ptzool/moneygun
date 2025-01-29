class Project < ApplicationRecord
  belongs_to :organization
  has_many :tasks
  validates :name, presence: true, uniqueness: { scope: :organization_id }
end
