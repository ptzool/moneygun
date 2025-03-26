class Organizations::TasksController < Organizations::BaseController
  before_action :set_task, only: [ :show, :edit, :update, :destroy, :destroy_attachment ]
  before_action :set_select_collections, only: [ :new, :create, :edit, :update ]
  before_action :set_default_breadcrumbs
  before_action :add_task_breadcrumb, only: [ :show, :edit ]


  def index
    authorize Task
    @tasks = policy_scope(@organization.tasks)
      .filter_by_priority(params[:priority])
      .filter_by_status(params[:status])
      .filter_by_planned_start_date(params[:planned_start_date])
      .filter_by_planned_end_date(params[:planned_end_date])
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
    @task_attachment = @task.task_attachments.find_by!(id: params[:attachment_id])
    authorize @task_attachment, :destroy?

    @task_attachment.purge
    redirect_to organization_task_url(@organization, @task), notice: t("tasks.attachments.destroy.success"), status: :see_other
  end

  private

  def set_task
    @task = policy_scope(@organization.tasks).find_by!(id: params[:id])
    authorize @task
  rescue ActiveRecord::RecordNotFound
    redirect_to organization_tasks_path, alert: t("tasks.not_found")
  end

  def set_select_collections
    @projects = @organization.projects.where(archived: false)
    @assignees = @organization.memberships
    @reporters = @organization.memberships
  end

  def task_params
    params.require(:task).permit(
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
    )
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
end
