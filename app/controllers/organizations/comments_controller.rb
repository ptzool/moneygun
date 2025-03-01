class Organizations::CommentsController < Organizations::BaseController
  before_action :set_task, only: [ :create ]
  before_action :authorize_task, only: [ :create ]

  def create
    @comment = Comment.new(comment_params)
    authorize @comment

    if @comment.save
      redirect_to organization_task_url(@organization, @task), notice: t("comments.create.success")
    else
      redirect_to organization_task_url(@organization, @task), alert: t("comments.create.failure")
    end
  end

  private

  def set_task
    @task = @organization.tasks.find_by!(id: params[:task_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to organization_tasks_path, alert: t("tasks.not_found")
  end

  def authorize_task
    authorize @task
  end

  def comment_params
    params.require(:comment).permit(:body).merge(
      membership_id: @current_membership.id,
      task_id: @task.id
    )
  end
end
