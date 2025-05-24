class TaskCategoryPolicy < Organization::BasePolicy
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
    membership.admin?
  end

  def edit?
    update?
  end

  def update?
    membership.admin?
  end

  def destroy?
    membership.admin?
  end

  class Scope < Organization::BasePolicy::Scope
    def resolve
      scope.all
    end
  end
end