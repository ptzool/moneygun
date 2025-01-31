class CommentPolicy < Organization::BasePolicy
  def index?
    membership.admin? || membership.member?
  end

  def show?
    membership.admin? || membership.member?
  end

  def new?
    create?
  end

  def create?
    membership.admin? || membership.member?
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
end
