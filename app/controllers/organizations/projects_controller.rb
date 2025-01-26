class Organizations::ProjectsController < Organizations::BaseController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # GET /organizations/1//projects
  def index
    authorize Project
    @projects = @organization.projects
  end

  # GET /organizations/1/projects/1 or /organizations/1/projects/1.json
  def show
  end

  # GET /organizations/1/projects/new
  def new
    @project = @organization.projects.new
    authorize @project
  end

  # GET /organizations/1/projects/1/edit
  def edit
  end

  # POST /organizations/1/projects or /organizations/1/projects.json
  def create
    @project = @organization.projects.new(project_params)
    authorize @project

    if @project.save
      redirect_to organization_project_url(@organization, @project), notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /organizations/1/projects/1 or /organizations/1/projects/1.json
  def update
    if @project.update(project_params)
      redirect_to organization_project_url(@organization, @project), notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /organizations/1/projects/1 or /organizations/1/projects/1.json
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
    params.require(:project).permit(:organization_id, :name, :description)
  end
end
