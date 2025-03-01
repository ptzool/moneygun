class Organizations::TaskTimetrackingsController < Organizations::BaseController
  before_action :set_task, only: [ :create ]
  before_action :set_task_timetracking, only: [ :destroy ]

  def index
    @task_timetrackings = policy_scope(TaskTimetracking)
    authorize @task_timetrackings
  end

  def create
    @task_timetracking = @task.task_timetrackings.new(task_timetracking_params)
    authorize @task_timetracking

    if @task_timetracking.save
      redirect_to organization_task_url(@organization, @task), notice: t("task_timetrackings.create.success")
    else
      redirect_to organization_task_url(@organization, @task), alert: t("task_timetrackings.create.failure")
    end
  end

  def destroy
    authorize @task_timetracking
    @task_timetracking.destroy!

    respond_to do |format|
      format.html { redirect_to organization_task_url(@organization, @task_timetracking.task), notice: t("task_timetrackings.destroy.success"), status: :see_other }
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
    @task_timetracking = TaskTimetracking.find_by!(id: params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to organization_tasks_path(@organization), alert: t("task_timetrackings.not_found")
  end

  def task_timetracking_params
    params.require(:task_timetracking).permit(:date, :start, :end, :duration).merge(
      membership_id: @current_membership.id
    )
  end
end
