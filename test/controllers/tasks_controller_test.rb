require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @organization = organizations(:organization_one)
    @user = users(:user_one)
    @task = tasks(:task_one)
    sign_in @user
  end

  test "should get index" do
    get organization_tasks_url(@organization)
    assert_response :success
    assert_not_nil assigns(:tasks)
  end

  test "should get new" do
    get new_organization_task_url(@organization)
    assert_response :success
    assert_not_nil assigns(:task)
    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:assignees)
    assert_not_nil assigns(:reporters)
  end

  test "should create task" do
    assert_difference('Task.count') do
      post organization_tasks_url(@organization), params: {
        task: {
          name: "New Task",
          project_id: projects(:project_one).id, # Project ID-t használj
          assignee_id: memberships(:membership_one).id, # Membership ID-t használj
          reporter_id: memberships(:membership_two).id
        }
      }
    end
    assert_redirected_to organization_task_path(@organization, Task.last)
  end

  test "should not create task with invalid params" do
    assert_no_difference("Task.count") do
      post organization_tasks_url(@organization), params: {
        task: { name: "" }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should show task" do
    get organization_task_url(@organization, @task)
    assert_response :success
    assert_not_nil assigns(:comment)
  end

  test "should get edit" do
    get edit_organization_task_url(@organization, @task)
    assert_response :success
    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:assignees)
    assert_not_nil assigns(:reporters)
  end

  test "should update task" do
    patch organization_task_url(@organization, @task), params: {
      task: { name: "Updated Task Name" }
    }
    assert_redirected_to organization_task_url(@organization, @task)
    assert_equal "Task was successfully updated.", flash[:notice]
    @task.reload
    assert_equal "Updated Task Name", @task.name
  end

  test "should not update task with invalid params" do
    patch organization_task_url(@organization, @task), params: {
      task: { name: "" }
    }
    assert_response :unprocessable_entity
  end

  test "should destroy task" do
    assert_difference("Task.count", -1) do
      delete organization_task_url(@organization, @task)
    end

    assert_redirected_to organization_tasks_url(@organization)
    assert_equal "Task was successfully destroyed.", flash[:notice]
  end

  test "should destroy task attachment" do
    @task.task_attachments.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test.csv")), filename: "test.csv")
    attachment = @task.task_attachments.first

    assert_difference -> { @task.task_attachments.count }, -1 do
      delete destroy_attachment_organization_task_url(@organization, @task, attachment_id: attachment.id)
    end

    assert_redirected_to organization_task_url(@organization, @task)
    assert_equal "Task attachment was successfully deleted.", flash[:notice]
  end

  test "should handle record not found" do
    get organization_task_url(@organization, id: "invalid")
    assert_redirected_to organization_tasks_path
  end

  test "should authorize actions" do
    sign_out @user
    get organization_tasks_url(@organization)
    assert_redirected_to new_user_session_path
  end
end
