class Task < ApplicationRecord
  belongs_to :organization
  belongs_to :project

  has_many :comments, dependent: :destroy

  has_paper_trail
end
