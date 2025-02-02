class Employee < ApplicationRecord
  belongs_to :organization
  belongs_to :membership

  has_many :employee_documents, dependent: :destroy

  validates :membership_id, uniqueness: { message: "is already an employee" }

end
