class Organizations::ProjectsController < Organizations::BaseController
  before_action :set_project, only: [ :show, :edit, :update, :destroy ]

  def index
    authorize Project
    @projects = @organization.projects.page(params[:page])
  end

  def show
  end

  def new
    @project = @organization.projects.new
    @project_managers = @organization.memberships

    authorize @project
  end

  def edit
    @project_managers = @organization.memberships
  end

  def create
    @project = @organization.projects.new(project_params)
    authorize @project

    if @project.save
      redirect_to organization_project_url(@organization, @project), notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      redirect_to organization_project_url(@organization, @project), notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy!

    redirect_to organization_projects_url(@organization), notice: "Project was successfully destroyed."
  end

  private

  def set_project
    @project = @organization.projects.find(params[:id])
    authorize @project

  rescue ActiveRecord::RecordNotFound
    redirect_to projects_path
  end

  def project_params
    params.require(:project).permit(:organization_id, :name, :description, :project_manager_id, :project_logo)
  end
end
