require "test_helper"

class MembershipWorklogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @membership_worklog = membership_worklogs(:one)
  end

  test "should get index" do
    get membership_worklogs_url
    assert_response :success
  end

  test "should get new" do
    get new_membership_worklog_url
    assert_response :success
  end

  test "should create membership_worklog" do
    assert_difference("MembershipWorklog.count") do
      post membership_worklogs_url, params: { membership_worklog: { check_in: @membership_worklog.check_in, check_out: @membership_worklog.check_out, date: @membership_worklog.date, membership_id: @membership_worklog.membership_id, organization_id: @membership_worklog.organization_id } }
    end

    assert_redirected_to membership_worklog_url(MembershipWorklog.last)
  end

  test "should show membership_worklog" do
    get membership_worklog_url(@membership_worklog)
    assert_response :success
  end

  test "should get edit" do
    get edit_membership_worklog_url(@membership_worklog)
    assert_response :success
  end

  test "should update membership_worklog" do
    patch membership_worklog_url(@membership_worklog), params: { membership_worklog: { check_in: @membership_worklog.check_in, check_out: @membership_worklog.check_out, date: @membership_worklog.date, membership_id: @membership_worklog.membership_id, organization_id: @membership_worklog.organization_id } }
    assert_redirected_to membership_worklog_url(@membership_worklog)
  end

  test "should destroy membership_worklog" do
    assert_difference("MembershipWorklog.count", -1) do
      delete membership_worklog_url(@membership_worklog)
    end

    assert_redirected_to membership_worklogs_url
  end
end
