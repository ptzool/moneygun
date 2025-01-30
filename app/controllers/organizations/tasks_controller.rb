class Organizations::TasksController < Organizations::BaseController
  before_action :set_task, only: [ :show, :edit, :update, :destroy ]

  # GET /tasks
  def index
    authorize Task
    @tasks = @organization.tasks.page(params[:page])
  end

  # GET /tasks/1 or /tasks/1.json
  def show
    @comment = Comment.new
  end

  # GET /tasks/new
  def new
    @task = @organization.tasks.new
    @projects = @organization.projects

    authorize @task
  end

  # GET /tasks/1/edit
  def edit
    @projects = @organization.projects
  end

  # POST /organizations/1/tasks or /organizations/1/tasks.json
  def create
    @task = @organization.tasks.new(task_params)
    authorize @task

    if @task.save
      redirect_to organization_task_url(@organization, @task), notice: "Task was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /organizations/1/tasks/1 or /organizations/1/tasks/1.json
  def update
    if @task.update(task_params)
      redirect_to organization_task_url(@organization, @task), notice: "Task was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /organizations/1/task/1 or /organizations/1/tasks/1.json
  def destroy
    @task.destroy!

    redirect_to organization_tasks_url(@organization), notice: "Task was successfully destroyed."
  end

  private

  def set_task
    @task = @organization.tasks.find(params[:id])
    authorize @task

  rescue ActiveRecord::RecordNotFound
    redirect_to organization_tasks_path()
  end

  def task_params
    params.require(:task).permit(:organization_id, :project_id, :name, :description, :planned_start_date, :planned_end_date, :priority)
  end
end
