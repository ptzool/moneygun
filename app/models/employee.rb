class Employee < ApplicationRecord
  belongs_to :organization
  belongs_to :membership

  validates :membership_id, uniqueness: { message: "is already an employee" }

end
