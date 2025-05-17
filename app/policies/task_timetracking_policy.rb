class TaskTimetrackingPolicy < Organization::BasePolicy
  def show?
    membership.admin? || membership.employee? || is_own_timetracking?
  end

  def create?
    membership.admin? || membership.employee? || is_task_assignee?
  end

  def update?
    membership.admin? || is_own_timetracking?
  end

  def destroy?
    membership.admin? || is_own_timetracking?
  end

  private

  def is_task_assignee?
    # Check if current user is the assignee of the task
    record.task.assignee_id == membership.id
  end

  def is_own_timetracking?
    # Check if current user created this time tracking entry
    record.membership_id == membership.id
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
