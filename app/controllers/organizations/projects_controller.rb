class Organizations::ProjectsController < Organizations::BaseController
  before_action :set_project, only: [ :show, :edit, :update, :destroy, :destroy_attachment ]
  before_action :set_select_collections, only: [ :new, :create, :edit, :update ]
  before_action :set_default_breadcrumbs

  def index
    authorize Project
    @projects = policy_scope(@organization.projects)
      .order(created_at: :desc)
      .by_archived(params[:archived])
      .page(params[:page])
      .per(25)
  end

  def show
    add_breadcrumb @project.name, organization_project_path(@organization, @project)

    @project_tasks = policy_scope(@project.tasks)
      .by_priority(params[:priority])
      .by_status(params[:status])
      .order(created_at: :desc)
      .page(params[:page]).per(10)
  end

  def new
    @project = @organization.projects.new(
      project_manager_id: @organization.memberships.find_by(user_id: current_user.id)&.id
    )
    authorize @project
  end

  def edit
    add_breadcrumb @project.name, organization_project_path(@organization, @project)
  end

  def create
    @project = @organization.projects.new(project_params)
    authorize @project

    if @project.save
      redirect_to organization_project_url(@organization, @project), notice: t("projects.create.success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      redirect_to organization_project_url(@organization, @project), notice: t("projects.update.success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy!
    redirect_to organization_projects_url(@organization), notice: t("projects.destroy.success")
  end

  def destroy_attachment
    @project_attachment = @project.project_attachments.find_by!(id: params[:attachment_id])
    @project_attachment.purge
    redirect_to organization_project_url(@organization, @project), notice: t("projects.attachments.destroy.success"), status: :see_other
  end

  private

  def set_project
    @project = @organization.projects.find_by!(id: params[:id])
    authorize @project
  rescue ActiveRecord::RecordNotFound
    redirect_to organization_projects_path(@organization), alert: t("projects.not_found")
  end

  def set_select_collections
    @project_managers = @organization.memberships
  end

  def project_params
    params.require(:project).permit(
      :name,
      :description,
      :project_manager_id,
      :project_logo,
      :archived,
      project_attachments: []
    )
  end

  def set_default_breadcrumbs
    add_breadcrumb t("breadcrumbs.home"), :root_path
    add_breadcrumb t("breadcrumbs.organizations"), :organizations_path
    add_breadcrumb @organization.name, organization_path(@organization)
    add_breadcrumb t("breadcrumbs.projects"), :organization_projects_path
  end
end
