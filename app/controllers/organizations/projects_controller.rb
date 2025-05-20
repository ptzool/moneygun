class Organizations::ProjectsController < Organizations::BaseController
  # CSRF védelem explicit beállítása
  protect_from_forgery with: :exception

  # SSL kényszerítése termelési környezetben
  # force_ssl if: :ssl_configured?

  before_action :set_project, only: [ :show, :edit, :update, :destroy, :destroy_attachment ]
  before_action :set_select_collections, only: [ :new, :create, :edit, :update ]
  before_action :set_default_breadcrumbs
  before_action :add_project_breadcrumb, only: [ :show, :edit ]
  before_action :validate_file_uploads, only: [ :create, :update ]

  def index
    authorize Project
    @projects = policy_scope(@organization.projects)
      .joins(:project_members)
      .where(project_members: { user_id: current_user.id })
      .filter_by_archived(sanitize_boolean_param(params[:archived]))
      .newest_first
      .page(params[:page])
      .per(25)
  end

  def show
    authorize @project
    @project_tasks = policy_scope(@project.tasks)
      .filter_by_priority(sanitize_string_param(params[:priority]))
      .filter_by_status(sanitize_string_param(params[:status]))
      .newest_first
      .page(params[:page])
      .per(10)
  end

  def new
    @project = @organization.projects.new(
      project_manager_id: @organization.memberships.find_by(user_id: current_user.id)&.id
    )
    authorize @project
  end

  def edit
    authorize @project
  end

  def create
    @project = @organization.projects.new(project_params)
    authorize @project

    if @project.save
      # Add the creator as an owner of the project
      @project.project_members.create(user: current_user, role: 'owner')
      redirect_to organization_project_url(@organization, @project), notice: t("projects.create.success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @project

    if @project.update(project_params)
      redirect_to organization_project_url(@organization, @project), notice: t("projects.update.success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @project

    @project.destroy!
    redirect_to organization_projects_url(@organization), notice: t("projects.destroy.success")
  end

  def destroy_attachment
    authorize @project

    # Biztonságos attachment keresés és külön authorizáció
    @project_attachment = @project.project_attachments.find_by!(id: params[:attachment_id])
    authorize @project_attachment, :destroy?

    @project_attachment.purge
    redirect_to organization_project_url(@organization, @project), notice: t("projects.attachments.destroy.success"), status: :see_other
  end

  private

  def ssl_configured?
    Rails.env.production? || Rails.env.staging?
  end

  def set_project
    @project = @organization.projects
      .joins(:project_members)
      .where(project_members: { user_id: current_user.id })
      .find_by!(id: params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to organization_projects_path(@organization), alert: t("projects.not_found")
  end

  def set_select_collections
    @project_managers = @organization.memberships
  end

  def project_params
    # Csak engedélyezett paraméterek szigorú szűrése
    params.require(:project).permit(
      :name,
      :description,
      :project_manager_id,
      :archived,
      :project_logo,
      project_attachments: []
    )
  end

  # Paraméter sanitizáció metódusok
  def sanitize_boolean_param(param)
    return nil if param.blank?
    ActiveRecord::Type::Boolean.new.cast(param.to_s)
  end

  def sanitize_string_param(param)
    return nil if param.blank?
    param.to_s
  end

  # Fájl feltöltés validáció
  def validate_file_uploads
    if params.dig(:project, :project_logo)
      validate_file(params[:project][:project_logo])
    end

    if params.dig(:project, :project_attachments)
      Array(params[:project][:project_attachments]).each do |attachment|
        validate_file(attachment)
      end
    end
  end

  def validate_file(file)
    return unless file.is_a?(ActionDispatch::Http::UploadedFile) || file.is_a?(ActiveStorage::Blob)

    allowed_types = [ "image/jpeg", "image/png", "application/pdf" ]
    max_size = 10.megabytes

    unless allowed_types.include?(file.content_type)
      raise ArgumentError, "Invalid file type"
    end

    if file.size > max_size
      raise ArgumentError, "File too large"
    end
  rescue ArgumentError => e
    Rails.logger.error("File validation error: #{e.message}")
    flash[:alert] = t("errors.file_validation")
    raise
  end

  # Breadcrumb metódusok
  def set_default_breadcrumbs
    add_breadcrumb t("breadcrumbs.home"), :root_path
    add_breadcrumb t("breadcrumbs.organizations"), :organizations_path
    add_breadcrumb @organization.name, organization_path(@organization)
    add_breadcrumb t("breadcrumbs.projects"), :organization_projects_path
  end

  def add_project_breadcrumb
    add_breadcrumb @project.name, organization_project_path(@organization, @project)
  end
end
