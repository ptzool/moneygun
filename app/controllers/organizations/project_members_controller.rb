class Organizations::ProjectMembersController < Organizations::BaseController
  before_action :set_project
  before_action :authorize_project_owner!, except: [:index]

  def index
    @project_members = @project.project_members.includes(:user)
    @available_users = User.where.not(id: @project.members.pluck(:id))
  end

  def create
    @project_member = @project.project_members.build(project_member_params)

    if @project_member.save
      redirect_to organization_project_project_members_path(@organization, @project), notice: 'Member was successfully added to the project.'
    else
      redirect_to organization_project_project_members_path(@organization, @project), alert: "Failed to add member to the project: #{@project_member.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @project_member = @project.project_members.find(params[:id])
    
    # Prevent removing the last owner
    if @project_member.role == 'owner' && @project.project_members.owners.count <= 1
      redirect_to organization_project_project_members_path(@organization, @project), alert: 'Cannot remove the last owner of the project.'
      return
    end
    
    if @project_member.destroy
      redirect_to organization_project_project_members_path(@organization, @project), notice: 'Member was successfully removed from the project.'
    else
      redirect_to organization_project_project_members_path(@organization, @project), alert: 'Failed to remove member from the project.'
    end
  end

  private


  def set_project
    @project = @organization.projects.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to organization_projects_path(@organization), alert: 'Project not found.'
  end

  def project_member_params
    params.require(:project_member).permit(:user_id, :role)
  end

  def authorize_project_owner!
    unless @project.project_members.owners.exists?(user: current_user) || @organization.owner?(current_user)
      redirect_to organization_project_path(@organization, @project), alert: 'Only project owners can manage members.'
    end
  end
end