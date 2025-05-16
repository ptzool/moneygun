class TaskPolicy < Organization::BasePolicy
  def index?
    membership.admin? || membership.employee?
  end

  def show?
    membership.admin? || membership.employee?
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
    membership.admin? || membership.employee?
  end

  def destroy?
    membership.admin? || membership.employee?
  end

  def destroy_attachment?
    membership.admin? || membership.employee?
  end

  class Scope < Organization::BasePolicy::Scope
    def resolve
      if membership.admin?
        scope.all
      else
        scope.where(reporter_id: membership.id).or(scope.where(assignee_id: membership.id))
      end
    end
  end
end
