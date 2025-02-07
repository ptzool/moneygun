require "application_system_test_case"

class MembershipWorklogsTest < ApplicationSystemTestCase
  setup do
    @membership_worklog = membership_worklogs(:one)
  end

  test "visiting the index" do
    visit membership_worklogs_url
    assert_selector "h1", text: "Membership worklogs"
  end

  test "should create membership worklog" do
    visit membership_worklogs_url
    click_on "New membership worklog"

    fill_in "Check in", with: @membership_worklog.check_in
    fill_in "Check out", with: @membership_worklog.check_out
    fill_in "Date", with: @membership_worklog.date
    fill_in "Membership", with: @membership_worklog.membership_id
    fill_in "Organization", with: @membership_worklog.organization_id
    click_on "Create Membership worklog"

    assert_text "Membership worklog was successfully created"
    click_on "Back"
  end

  test "should update Membership worklog" do
    visit membership_worklog_url(@membership_worklog)
    click_on "Edit this membership worklog", match: :first

    fill_in "Check in", with: @membership_worklog.check_in.to_s
    fill_in "Check out", with: @membership_worklog.check_out.to_s
    fill_in "Date", with: @membership_worklog.date
    fill_in "Membership", with: @membership_worklog.membership_id
    fill_in "Organization", with: @membership_worklog.organization_id
    click_on "Update Membership worklog"

    assert_text "Membership worklog was successfully updated"
    click_on "Back"
  end

  test "should destroy Membership worklog" do
    visit membership_worklog_url(@membership_worklog)
    click_on "Destroy this membership worklog", match: :first

    assert_text "Membership worklog was successfully destroyed"
  end
end
