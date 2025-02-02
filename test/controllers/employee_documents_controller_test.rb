require "test_helper"

class EmployeeDocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @employee_document = employee_documents(:one)
  end

  test "should get index" do
    get employee_documents_url
    assert_response :success
  end

  test "should get new" do
    get new_employee_document_url
    assert_response :success
  end

  test "should create employee_document" do
    assert_difference("EmployeeDocument.count") do
      post employee_documents_url, params: { employee_document: { employee_id: @employee_document.employee_id, organization_id: @employee_document.organization_id } }
    end

    assert_redirected_to employee_document_url(EmployeeDocument.last)
  end

  test "should show employee_document" do
    get employee_document_url(@employee_document)
    assert_response :success
  end

  test "should get edit" do
    get edit_employee_document_url(@employee_document)
    assert_response :success
  end

  test "should update employee_document" do
    patch employee_document_url(@employee_document), params: { employee_document: { employee_id: @employee_document.employee_id, organization_id: @employee_document.organization_id } }
    assert_redirected_to employee_document_url(@employee_document)
  end

  test "should destroy employee_document" do
    assert_difference("EmployeeDocument.count", -1) do
      delete employee_document_url(@employee_document)
    end

    assert_redirected_to employee_documents_url
  end
end
