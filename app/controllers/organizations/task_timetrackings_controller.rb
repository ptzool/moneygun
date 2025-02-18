class Organizations::TaskTimetrackingsController < Organizations::BaseController
  before_action :set_task, only: [ :create ]

  def index
    @task_timetrackings = TaskTimetracking.all
    authorize @task_timetrackings
  end

  def create
    @task_timetracking = TaskTimetracking.new(task_timetracking_params)

    if @task_timetracking.save
      redirect_to organization_task_url(@organization, @task), notice: "Time tracking was successfully created."
    else
      redirect_to organization_task_url(@organization, @task), alert: "Time tracking was not created."
    end
  end

  def destroy
    @task_timetracking.destroy!
    respond_to do |format|
      format.html { redirect_to task_timetrackings_url, status: :see_other, notice: "Task timetracking was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  def set_task
    @task = @organization.tasks.find(params[:task_id])
    authorize @task
  end

  def task_timetracking_params
    params.require(:task_timetracking).permit(:task_id, :membership_id, :date, :start, :end, :duration).merge(membership_id: @current_membership.id, task_id: @task.id)
  end
end
