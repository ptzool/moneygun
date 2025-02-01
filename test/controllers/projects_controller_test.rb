require 'test_helper'

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @organization = organizations(:organization_one)
    @user = users(:user_one)
    @project = projects(:project_one)
    sign_in @user
  end

  test "should get index" do
    get organization_projects_url(@organization)
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  test "should get new" do
    get new_organization_project_url(@organization)
    assert_response :success
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:project_managers)
  end

  test "should create project" do
    assert_difference('Project.count') do
      post organization_projects_url(@organization), params: {
        project: {
          name: "New Project",
          description: "Project description",
          project_manager_id: memberships(:membership_one).id
        }
      }
    end

    assert_redirected_to organization_project_url(@organization, Project.last)
    assert_equal "Project was successfully created.", flash[:notice]
  end

  test "should not create project with invalid params" do
    assert_no_difference('Project.count') do
      post organization_projects_url(@organization), params: {
        project: { name: "" }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should show project" do
    get organization_project_url(@organization, @project)
    assert_response :success
  end

  test "should get edit" do
    get edit_organization_project_url(@organization, @project)
    assert_response :success
    assert_not_nil assigns(:project_managers)
  end

  test "should update project" do
    patch organization_project_url(@organization, @project), params: {
      project: { name: "Updated Project Name" }
    }
    assert_redirected_to organization_project_url(@organization, @project)
    assert_equal "Project was successfully updated.", flash[:notice]
    @project.reload
    assert_equal "Updated Project Name", @project.name
  end

  test "should not update project with invalid params" do
    patch organization_project_url(@organization, @project), params: {
      project: { name: "" }
    }
    assert_response :unprocessable_entity
  end

  test "should destroy project" do
    assert_difference('Project.count', -1) do
      delete organization_project_url(@organization, @project)
    end

    assert_redirected_to organization_projects_url(@organization)
    assert_equal "Project was successfully destroyed.", flash[:notice]
  end

  test "should handle record not found" do
    get organization_project_url(@organization, id: 'invalid')
    assert_redirected_to projects_path
  end

  test "should authorize actions" do
    sign_out @user
    get organization_projects_url(@organization)
    assert_redirected_to new_user_session_path
  end

  test "should paginate projects" do
    30.times { create(:project, organization: @organization) }
    get organization_projects_url(@organization, page: 2)
    assert_equal 10, assigns(:projects).size
    assert_equal 2, assigns(:projects).current_page
  end

  test "should attach project logo" do
    file = fixture_file_upload('test/fixtures/files/logo.png', 'image/png')
    assert_difference -> { ActiveStorage::Attachment.count } do
      post organization_projects_url(@organization), params: {
        project: {
          name: "Logo Project",
          project_logo: file
        }
      }
    end
    assert Project.last.project_logo.attached?
  end
end
