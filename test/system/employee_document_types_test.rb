require "application_system_test_case"

class EmployeeDocumentTypesTest < ApplicationSystemTestCase
  setup do
    @employee_document_type = employee_document_types(:one)
  end

  test "visiting the index" do
    visit employee_document_types_url
    assert_selector "h1", text: "Employee document types"
  end

  test "should create employee document type" do
    visit employee_document_types_url
    click_on "New employee document type"

    fill_in "Name", with: @employee_document_type.name
    click_on "Create Employee document type"

    assert_text "Employee document type was successfully created"
    click_on "Back"
  end

  test "should update Employee document type" do
    visit employee_document_type_url(@employee_document_type)
    click_on "Edit this employee document type", match: :first

    fill_in "Name", with: @employee_document_type.name
    click_on "Update Employee document type"

    assert_text "Employee document type was successfully updated"
    click_on "Back"
  end

  test "should destroy Employee document type" do
    visit employee_document_type_url(@employee_document_type)
    click_on "Destroy this employee document type", match: :first

    assert_text "Employee document type was successfully destroyed"
  end
end
