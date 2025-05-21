class OrganizationsController < ApplicationController
  before_action :set_organization, only: %i[show edit update destroy]
  before_action :set_default_breadcrumbs
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @organizations = policy_scope(current_user.organizations)
      .includes(:users, :memberships, :projects)
      .newest_first
      .to_a
  end

  def show
    authorize @organization
    add_breadcrumb @organization.name, organization_path(@organization), only: %i[show]

    @recent_members = @organization.memberships.includes(:user).limit(5).to_a

    @projects = policy_scope(@organization.projects)
      .joins(:project_members)
      .where(project_members: { user_id: current_user.id })
      .newest_first

    @projects_count = @organization.projects.count
    @members_count = @organization.memberships.count
  end

  def new
    add_breadcrumb "New Organization", :new_organization_path, only: %i[new create]
    @organization = Organization.new
    authorize @organization
  end

  def edit
    authorize @organization
  end

  def create
    @organization = Organization.new(organization_params)
    @organization.owner = current_user
    @organization.memberships.build(user: current_user, role: Membership.roles[:admin])
    authorize @organization

    if @organization.save
      redirect_to organization_url(@organization), notice: "Organization was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @organization
    if @organization.update(organization_params)
      redirect_to organization_url(@organization), notice: "Organization was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @organization
    @organization.destroy!

    redirect_to organizations_url, notice: "Organization was successfully destroyed."
  end

  private

  def set_organization
    # Gyorsítótárazott lekérdezés egy szervezet adataihoz és kapcsolódó objektumaihoz
    @organization =Organization.includes(
        :users,
        :owner,
        memberships: :user,
        projects: [ :project_manager, { tasks: [ :assignee, :reporter ] } ]
      ).find_by(id: params[:id])

    if @organization.nil?
      redirect_to organizations_path, alert: "Organization not found."
      return
    end

    @current_membership ||= current_user.memberships.find_by(organization: @organization)
    authorize @organization
  rescue ActiveRecord::RecordNotFound
    redirect_to organizations_path, alert: "Organization not found."
  end

  def organization_params
    permitted_attributes = [ :name, :address, :registration_number, :tax_number, :iban ]

    # Only allow valid email formats
    if params[:organization][:email].present? && params[:organization][:email].match?(/\A[^@\s]+@[^@\s]+\z/)
      permitted_attributes << :email
    end

    # Add logo if included in the params
    permitted_attributes << :logo if params[:organization].key?(:logo)

    params.require(:organization).permit(permitted_attributes)
  end

  def set_default_breadcrumbs
    add_breadcrumb "Home", :root_path
    add_breadcrumb "Organizations", :organizations_path
  end
end
