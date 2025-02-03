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

  class Scope
    def initialize(membership, scope)
      raise Pundit::NotAuthorizedError, "must be logged in" unless membership

      @membership = membership
      @scope = scope
    end

    def resolve
      if membership.admin?
        scope.all
      else
        scope.where(reporter_id: membership.id).or(scope.where(assignee_id: membership.id))
      end
    end

    private

    attr_reader :membership, :scope
  end
end
