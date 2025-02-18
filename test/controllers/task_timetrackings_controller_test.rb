require "test_helper"

class TaskTimetrackingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @task_timetracking = task_timetrackings(:one)
  end

  test "should get index" do
    get task_timetrackings_url
    assert_response :success
  end

  test "should get new" do
    get new_task_timetracking_url
    assert_response :success
  end

  test "should create task_timetracking" do
    assert_difference("TaskTimetracking.count") do
      post task_timetrackings_url, params: { task_timetracking: { date: @task_timetracking.date, duration: @task_timetracking.duration, end: @task_timetracking.end, membership_id: @task_timetracking.membership_id, start: @task_timetracking.start, task_id: @task_timetracking.task_id } }
    end

    assert_redirected_to task_timetracking_url(TaskTimetracking.last)
  end

  test "should show task_timetracking" do
    get task_timetracking_url(@task_timetracking)
    assert_response :success
  end

  test "should get edit" do
    get edit_task_timetracking_url(@task_timetracking)
    assert_response :success
  end

  test "should update task_timetracking" do
    patch task_timetracking_url(@task_timetracking), params: { task_timetracking: { date: @task_timetracking.date, duration: @task_timetracking.duration, end: @task_timetracking.end, membership_id: @task_timetracking.membership_id, start: @task_timetracking.start, task_id: @task_timetracking.task_id } }
    assert_redirected_to task_timetracking_url(@task_timetracking)
  end

  test "should destroy task_timetracking" do
    assert_difference("TaskTimetracking.count", -1) do
      delete task_timetracking_url(@task_timetracking)
    end

    assert_redirected_to task_timetrackings_url
  end
end
