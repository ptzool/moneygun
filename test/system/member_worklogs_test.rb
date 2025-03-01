require "application_system_test_case"

class MemberWorklogsTest < ApplicationSystemTestCase
  setup do
    @member_worklog = member_worklogs(:one)
  end

  test "visiting the index" do
    visit member_worklogs_url
    assert_selector "h1", text: "Member worklogs"
  end

  test "should create member worklog" do
    visit member_worklogs_url
    click_on "New member worklog"

    fill_in "Date", with: @member_worklog.date
    fill_in "Membership", with: @member_worklog.membership_id
    fill_in "Organization", with: @member_worklog.organization_id
    fill_in "Type", with: @member_worklog.type
    click_on "Create Member worklog"

    assert_text "Member worklog was successfully created"
    click_on "Back"
  end

  test "should update Member worklog" do
    visit member_worklog_url(@member_worklog)
    click_on "Edit this member worklog", match: :first

    fill_in "Date", with: @member_worklog.date
    fill_in "Membership", with: @member_worklog.membership_id
    fill_in "Organization", with: @member_worklog.organization_id
    fill_in "Type", with: @member_worklog.type
    click_on "Update Member worklog"

    assert_text "Member worklog was successfully updated"
    click_on "Back"
  end

  test "should destroy Member worklog" do
    visit member_worklog_url(@member_worklog)
    click_on "Destroy this member worklog", match: :first

    assert_text "Member worklog was successfully destroyed"
  end
end
