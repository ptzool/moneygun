require "application_system_test_case"

class TaskTimetrackingsTest < ApplicationSystemTestCase
  setup do
    @task_timetracking = task_timetrackings(:one)
  end

  test "visiting the index" do
    visit task_timetrackings_url
    assert_selector "h1", text: "Task timetrackings"
  end

  test "should create task timetracking" do
    visit task_timetrackings_url
    click_on "New task timetracking"

    fill_in "Date", with: @task_timetracking.date
    fill_in "Duration", with: @task_timetracking.duration
    fill_in "End", with: @task_timetracking.end
    fill_in "Membership", with: @task_timetracking.membership_id
    fill_in "Start", with: @task_timetracking.start
    fill_in "Task", with: @task_timetracking.task_id
    click_on "Create Task timetracking"

    assert_text "Task timetracking was successfully created"
    click_on "Back"
  end

  test "should update Task timetracking" do
    visit task_timetracking_url(@task_timetracking)
    click_on "Edit this task timetracking", match: :first

    fill_in "Date", with: @task_timetracking.date
    fill_in "Duration", with: @task_timetracking.duration
    fill_in "End", with: @task_timetracking.end.to_s
    fill_in "Membership", with: @task_timetracking.membership_id
    fill_in "Start", with: @task_timetracking.start.to_s
    fill_in "Task", with: @task_timetracking.task_id
    click_on "Update Task timetracking"

    assert_text "Task timetracking was successfully updated"
    click_on "Back"
  end

  test "should destroy Task timetracking" do
    visit task_timetracking_url(@task_timetracking)
    click_on "Destroy this task timetracking", match: :first

    assert_text "Task timetracking was successfully destroyed"
  end
end
