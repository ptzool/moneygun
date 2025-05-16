class Organizations::TasksController < Organizations::BaseController
  include ActionView::Helpers::SanitizeHelper
  
  before_action :set_task, only: [:show, :edit, :update, :destroy, :destroy_attachment]
  before_action :set_select_collections, only: [:new, :create, :edit, :update]
  before_action :set_default_breadcrumbs
  before_action :add_task_breadcrumb, only: [:show, :edit]
  after_action :verify_authorized

  def index
    authorize Task
    @tasks = policy_scope(@organization.tasks)
      .filter_by_priority(sanitize_param(:priority))
      .filter_by_status(sanitize_param(:status))
      .filter_by_planned_start_date(sanitize_date_param(:planned_start_date))
      .filter_by_planned_end_date(sanitize_date_param(:planned_end_date))
      .newest_first
      .from_active_projects
      .page(params[:page])
      .per(15)
  end

  def show
    authorize @task
    @comment = Comment.new
    @task_timetracking = TaskTimetracking.new
  end

  def new
    @task = @organization.tasks.new
    authorize @task
  end

  def edit
    authorize @task
  end

  def create
    @task = @organization.tasks.new(task_params)
    authorize @task

    if @task.save
      redirect_to organization_task_url(@organization, @task), notice: t("tasks.create.success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @task
    
    if @task.update(task_params)
      redirect_to organization_task_url(@organization, @task), notice: t("tasks.update.success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @task
    
    @task.destroy!
    redirect_to organization_tasks_url(@organization), notice: t("tasks.destroy.success")
  end

  def destroy_attachment
    authorize @task
    
    @task_attachment = @task.task_attachments.find_by!(id: params[:attachment_id])
    authorize @task_attachment, :destroy?

    @task_attachment.purge
    redirect_to organization_task_url(@organization, @task), notice: t("tasks.attachments.destroy.success"), status: :see_other
  end

  private

  def set_task
    @task = policy_scope(@organization.tasks).find_by!(id: params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to organization_tasks_path, alert: t("tasks.not_found")
  end

  def set_select_collections
    @projects = policy_scope(@organization.projects).where(archived: false)
    @assignees = policy_scope(@organization.memberships)
    @reporters = policy_scope(@organization.memberships)
  end

  def task_params
    permitted_attributes = [
      :project_id,
      :name,
      :description,
      :planned_start_date,
      :planned_end_date,
      :priority,
      :assignee_id,
      :reporter_id,
      :status,
      task_attachments: []
    ]
    
    # Strip and sanitize text inputs
    params_to_sanitize = params.require(:task).permit(*permitted_attributes)
    
    [:name, :description].each do |attr|
      if params_to_sanitize[attr].present?
        params_to_sanitize[attr] = strip_tags(params_to_sanitize[attr].strip)
      end
    end

    params_to_sanitize
  end

  def set_default_breadcrumbs
    add_breadcrumb t("breadcrumbs.home"), :root_path
    add_breadcrumb t("breadcrumbs.organizations"), :organizations_path
    add_breadcrumb @organization.name, organization_path(@organization)
    add_breadcrumb t("breadcrumbs.tasks"), :organization_tasks_path
  end

  def add_task_breadcrumb
    add_breadcrumb @task.name, organization_task_path(@organization, @task)
  end

  # Security helpers
  def sanitize_param(param_name)
    value = params[param_name]
    return nil if value.blank?
    value.to_s
  end

  def sanitize_date_param(param_name)
    date_param = params[param_name]
    return nil if date_param.blank?
    
    begin
      Date.parse(date_param.to_s)
    rescue ArgumentError
      nil
    end
  end

  def strip_tags(text)
    sanitize(text, tags: [])
  end
end