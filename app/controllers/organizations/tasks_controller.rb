class Organizations::TasksController < Organizations::BaseController
  before_action :set_task, only: [ :show, :edit, :update, :destroy, :destroy_attachment]

  def index
    authorize Task
    @tasks = @organization.tasks.page(params[:page])
  end

  def show
    @comment = Comment.new
  end

  def new
    @task = @organization.tasks.new
    @projects = @organization.projects
    @assignees = @organization.memberships
    @reporters = @organization.memberships

    authorize @task
  end

  def edit
    @projects = @organization.projects
    @assignees = @organization.memberships
    @reporters = @organization.memberships
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
    @task = @organization.tasks.find(params[:id])
    authorize @task

  rescue ActiveRecord::RecordNotFound
    redirect_to organization_tasks_path()
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
      task_attachments: [])
  end
end
