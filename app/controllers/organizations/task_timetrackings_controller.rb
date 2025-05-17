class Organizations::TaskTimetrackingsController < Organizations::BaseController
  before_action :set_task, only: [ :new, :create ]
  before_action :set_task_timetracking, only: [ :show, :edit, :update, :destroy ]

  def index
    if params[:task_id].present?
      @task = @organization.tasks.find_by!(id: params[:task_id])
      @task_timetrackings = policy_scope(TaskTimetracking).where(task: @task)
      authorize @task_timetrackings
    else
      redirect_to organization_tasks_path(@organization), alert: t("tasks.select_task")
      return
    end
  end

  def show
    authorize @task_timetracking
  end

  def new
    if params[:task_id]
      @task = @organization.tasks.find_by!(id: params[:task_id])
      @task_timetracking = @task.task_timetrackings.new
    else
      redirect_to organization_tasks_path(@organization), alert: t("tasks.select_task")
      return
    end
    authorize @task_timetracking
  end

  def edit
    authorize @task_timetracking
  end

  def update
    authorize @task_timetracking

    if @task_timetracking.update(task_timetracking_params)
      redirect_to organization_task_task_timetracking_url(@organization, @task, @task_timetracking), notice: t("task_timetrackings.update.success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def create
    @task_timetracking = @task.task_timetrackings.new(task_timetracking_params)
    authorize @task_timetracking

    if @task_timetracking.save
      redirect_to organization_task_url(@organization, @task), notice: t("task_timetrackings.create.success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @task_timetracking
    task = @task_timetracking.task
    @task_timetracking.destroy!

    respond_to do |format|
      format.html { redirect_to params[:redirect_to] || organization_task_task_timetrackings_url(@organization, task), notice: t("task_timetrackings.destroy.success"), status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_task
    @task = @organization.tasks.find_by!(id: params[:task_id])
    authorize @task
  rescue ActiveRecord::RecordNotFound
    redirect_to organization_tasks_path(@organization), alert: t("tasks.not_found")
  end

  def set_task_timetracking
    @task_timetracking = TaskTimetracking.joins(:task).find_by!(id: params[:id], tasks: { organization_id: @organization.id })
    @task = @task_timetracking.task
  rescue ActiveRecord::RecordNotFound
    redirect_to organization_tasks_path(@organization), alert: t("task_timetrackings.not_found")
  end

  def task_timetracking_params
    params.require(:task_timetracking).permit(:date, :start, :end, :duration).merge(
      membership_id: @current_membership.id
    )
  end
end
