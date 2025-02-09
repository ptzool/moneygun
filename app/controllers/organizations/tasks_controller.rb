class Organizations::TasksController < Organizations::BaseController
  before_action :set_task, only: [ :show, :edit, :update, :destroy, :destroy_attachment ]
  before_action :set_select_collections, only: [ :new, :create, :edit, :update ]
  before_action :set_default_breadcrumbs

  def index
    authorize Task
    @tasks = policy_scope(@organization.tasks)
      .by_priority(params[:priority])
      .by_status(params[:status])
      .by_planned_start_date(params[:planned_start_date])
      .by_planned_end_date(params[:planned_end_date])
      .order(created_at: :desc)
      .page(params[:page]).per(15)
  end

  def show
    add_breadcrumb @task.name, organization_task_path(@organization, @task)
    @comment = Comment.new
  end

  def new
    @task = @organization.tasks.new
    authorize @task
  end

  def edit
    add_breadcrumb @task.name, organization_task_path(@organization, @task)
  end

  def create
    @task = @organization.tasks.new(task_params)
    authorize @task

    if @task.save
      redirect_to organization_task_url(@organization, @task), notice: "Task was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      redirect_to organization_task_url(@organization, @task), notice: "Task was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy!

    redirect_to organization_tasks_url(@organization), notice: "Task was successfully destroyed."
  end

  def destroy_attachment
    @task_attachment = @task.task_attachments.find(params[:attachment_id])
    @task_attachment.purge
    redirect_to organization_task_url(@organization, @task), notice: "Task attachment was successfully deleted.", status: 303
  end

  private

  def set_task
    @task = policy_scope(@organization.tasks).find(params[:id])
    authorize @task
  rescue ActiveRecord::RecordNotFound
    redirect_to organization_tasks_path()
  end

  def set_select_collections
    @projects = @organization.projects
    @assignees = @organization.memberships
    @reporters = @organization.memberships
  end

  def task_params
    params.require(:task).permit(
      :organization_id,
      :project_id,
      :name,
      :description,
      :planned_start_date,
      :planned_end_date,
      :priority,
      :assignee_id,
      :reporter_id,
      :priority,
      :status,
      task_attachments: [])
  end

  def set_default_breadcrumbs
    add_breadcrumb "Home", :root_path
    add_breadcrumb "Organizations", :organizations_path
    add_breadcrumb @organization.name, organization_path(@organization)
    add_breadcrumb "Tasks", :organization_tasks_path
  end
end
