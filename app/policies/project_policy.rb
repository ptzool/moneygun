class ProjectPolicy < Organization::BasePolicy
  def index?
    membership.admin? || membership.employee?
  end

  def show?
    membership.admin? || membership.employee? && record.project_members.exists?
  end

  def new?
    create?
  end

  def create?
    membership.admin? || membership.employee?
  end

  def edit?
    update?
  end

  def update?
    membership.admin? || record.project_members.owners.exists?(user: user)
  end

  def destroy?
    membership.admin? || record.project_members.owners.exists?(user: user)
  end

  def manage_members?
    membership.admin? || record.project_members.owners.exists?(user: user)
  end

  class Scope < Scope
    def resolve
      if membership.admin?
        scope.all
      else
        scope.joins(:project_members).where(project_members: { user_id: user.id })
      end
    end
  end
end
