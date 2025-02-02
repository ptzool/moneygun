require "application_system_test_case"

class EmployeeDocumentsTest < ApplicationSystemTestCase
  setup do
    @employee_document = employee_documents(:one)
  end

  test "visiting the index" do
    visit employee_documents_url
    assert_selector "h1", text: "Employee documents"
  end

  test "should create employee document" do
    visit employee_documents_url
    click_on "New employee document"

    fill_in "Employee", with: @employee_document.employee_id
    fill_in "Organization", with: @employee_document.organization_id
    click_on "Create Employee document"

    assert_text "Employee document was successfully created"
    click_on "Back"
  end

  test "should update Employee document" do
    visit employee_document_url(@employee_document)
    click_on "Edit this employee document", match: :first

    fill_in "Employee", with: @employee_document.employee_id
    fill_in "Organization", with: @employee_document.organization_id
    click_on "Update Employee document"

    assert_text "Employee document was successfully updated"
    click_on "Back"
  end

  test "should destroy Employee document" do
    visit employee_document_url(@employee_document)
    click_on "Destroy this employee document", match: :first

    assert_text "Employee document was successfully destroyed"
  end
end
