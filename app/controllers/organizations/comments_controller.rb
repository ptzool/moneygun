class Organizations::CommentsController < Organizations::BaseController
  before_action :set_task, only: [ :create ]

  def create
    @comment = Comment.new(comment_params)
    authorize @comment

    if @comment.save
      redirect_to organization_task_url(@organization, @task), notice: "Task was successfully created."
    else
      render :new, status: :unprocessable_entity
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

    # Uncomment to use Pundit permitted attributes
    # params.require(:comment).permit(policy(@comment).permitted_attributes)
  end
end
