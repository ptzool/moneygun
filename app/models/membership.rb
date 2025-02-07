class Membership < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  has_many :comments
  has_many :tasks
  has_many :projects
  has_many :assigned_tasks, class_name: "Task", foreign_key: "assignee_id"
  has_many :reported_tasks, class_name: "Task", foreign_key: "reporter_id"

  enum :role, { admin: "admin", accuontant: "accountant", employee: "employee" }

  validates_uniqueness_of :user_id, scope: :organization_id
  validates_uniqueness_of :organization_id, scope: :user_id

  validates :role, presence: true
  validate :cannot_change_role_if_only_admin, on: :update

  def try_destroy
    return false if organization.memberships.count == 1
    return false if role == "admin" && organization.memberships.where(role: "admin").count == 1

    destroy
  end

  private

  def cannot_change_role_if_only_admin
    return if organization.memberships.where(role: "admin").count > 1

    if role_changed? && role_was == "admin"
      errors.add(:base, "Role cannot be changed because this is the only admin.")
    end
  end
end
