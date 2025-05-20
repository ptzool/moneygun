class ProjectMemberPolicy < Organization::BasePolicy
  def create?
    membership.admin? || project.project_members.owners.exists?(user: user)
  end

  def destroy?
    return false if record.user == user && record.role == 'owner' && project.project_members.owners.count == 1
    membership.admin? || project.project_members.owners.exists?(user: user)
  end

  private

  def project
    record.is_a?(ProjectMember) ? record.project : record
  end

  class Scope < Scope
    def resolve
      if membership.admin?
        scope.all
      else
        scope.joins(:project).merge(Project.joins(:project_members).where(project_members: { user_id: user.id }))
      end
    end
  end
end