require "test_helper"

class MemberWorklogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @member_worklog = member_worklogs(:one)
  end

  test "should get index" do
    get member_worklogs_url
    assert_response :success
  end

  test "should get new" do
    get new_member_worklog_url
    assert_response :success
  end

  test "should create member_worklog" do
    assert_difference("MemberWorklog.count") do
      post member_worklogs_url, params: { member_worklog: { date: @member_worklog.date, membership_id: @member_worklog.membership_id, organization_id: @member_worklog.organization_id, type: @member_worklog.type } }
    end

    assert_redirected_to member_worklog_url(MemberWorklog.last)
  end

  test "should show member_worklog" do
    get member_worklog_url(@member_worklog)
    assert_response :success
  end

  test "should get edit" do
    get edit_member_worklog_url(@member_worklog)
    assert_response :success
  end

  test "should update member_worklog" do
    patch member_worklog_url(@member_worklog), params: { member_worklog: { date: @member_worklog.date, membership_id: @member_worklog.membership_id, organization_id: @member_worklog.organization_id, type: @member_worklog.type } }
    assert_redirected_to member_worklog_url(@member_worklog)
  end

  test "should destroy member_worklog" do
    assert_difference("MemberWorklog.count", -1) do
      delete member_worklog_url(@member_worklog)
    end

    assert_redirected_to member_worklogs_url
  end
end
