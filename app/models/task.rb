class Task < ApplicationRecord
  belongs_to :organization
  belongs_to :project
end
