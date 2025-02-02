class EmployeeDocument < ApplicationRecord
  belongs_to :organization
  belongs_to :employee

  has_one_attached :employee_document

end
