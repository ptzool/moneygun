class CommentPolicy < Organization::BasePolicy
  # def index?
  #   membership.admin?
  # end

  # def show?
  #   membership.admin?
  # end

  # def create?
  #   membership.admin?
  # end

  # def update?
  #   membership.admin?
  # end

  # def destroy?
  #   membership.admin?
  # end

  # https://github.com/varvet/pundit#strong-parameters
  # def permitted_attributes
  #   if membership.admin?
  #     [:name, :description]
  #   else
  #     [:name]
  #   end
  # end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
