require "test_helper"

class EmployeeDocumentTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @employee_document_type = employee_document_types(:one)
  end

  test "should get index" do
    get employee_document_types_url
    assert_response :success
  end

  test "should get new" do
    get new_employee_document_type_url
    assert_response :success
  end

  test "should create employee_document_type" do
    assert_difference("EmployeeDocumentType.count") do
      post employee_document_types_url, params: { employee_document_type: { name: @employee_document_type.name } }
    end

    assert_redirected_to employee_document_type_url(EmployeeDocumentType.last)
  end

  test "should show employee_document_type" do
    get employee_document_type_url(@employee_document_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_employee_document_type_url(@employee_document_type)
    assert_response :success
  end

  test "should update employee_document_type" do
    patch employee_document_type_url(@employee_document_type), params: { employee_document_type: { name: @employee_document_type.name } }
    assert_redirected_to employee_document_type_url(@employee_document_type)
  end

  test "should destroy employee_document_type" do
    assert_difference("EmployeeDocumentType.count", -1) do
      delete employee_document_type_url(@employee_document_type)
    end

    assert_redirected_to employee_document_types_url
  end
end
