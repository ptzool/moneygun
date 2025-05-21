class OrganizationPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.users.include?(user)
  end

  def new?
    create?
  end

  def create?
    true
  end

  def edit?
    membership = record.memberships.find_by(user:)
    membership&.admin?
  end

  def update?
    edit?
  end

  def destroy?
    record.owner == user
  end

  class Scope < Scope
    def resolve
      user.organizations
    end
  end
end
