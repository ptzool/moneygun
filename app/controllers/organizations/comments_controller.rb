class Organizations::CommentsController < Organizations::BaseController
  before_action :set_task, only: [ :create ]

  def create
    @comment = Comment.new(comment_params)
    authorize @comment

    if @comment.save
      redirect_to organization_task_url(@organization, @task), notice: "Comment was successfully created."
    else
      redirect_to organization_task_url(@organization, @task), alert: "Comment was not created."
    end
  end

  private
  def set_task
    @task = @organization.tasks.find(params[:task_id])
    authorize @task

  rescue ActiveRecord::RecordNotFound
    redirect_to organization_tasks_path()
  end

  def comment_params
    params.require(:comment).permit(:membership_id, :body).merge(membership_id: @current_membership.id, task_id: @task.id)
  end
end
