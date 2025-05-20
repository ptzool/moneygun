class OrganizationsController < ApplicationController
  before_action :set_organization, only: %i[show edit update destroy]
  before_action :set_default_breadcrumbs
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    scoped_organizations = policy_scope(current_user.organizations)

    # Cache-elés a szervezetek listájához
    @organizations = Rails.cache.fetch("organizations/user_#{current_user.id}/all", expires_in: 2.minutes) do
      scoped_organizations
        .includes(:users, :memberships, :projects)
        .newest_first
        .to_a
    end
  end

  def show
    add_breadcrumb @organization.name, organization_path(@organization), only: %i[show]

    # Cache-eljük a szervezet adatait és kapcsolódó elemeit
    @active_projects = Rails.cache.fetch("organizations/#{@organization.id}/active_projects", expires_in: 5.minutes) do
      @organization.projects.where(archived: false).includes(:project_manager).limit(4).to_a
    end

    @recent_members = Rails.cache.fetch("organizations/#{@organization.id}/recent_members", expires_in: 5.minutes) do
      @organization.memberships.includes(:user).limit(5).to_a
    end

    @projects_count = @organization.projects_count || @organization.projects.count
    @members_count = @organization.memberships_count || @organization.memberships.count
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
      # Töröljük a szervezetek listázásának cache-ét
      Rails.cache.delete_matched("organizations/user_*/all")
      redirect_to organization_url(@organization), notice: "Organization was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @organization
    if @organization.update(organization_params)
      # Töröljük az ehhez a szervezethez tartozó cache-eket
      Rails.cache.delete_matched("organizations/#{@organization.id}/*")
      Rails.cache.delete_matched("organizations/user_*/all")
      redirect_to organization_url(@organization), notice: "Organization was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @organization

    # Cache törlése a tényleges törlés előtt
    organization_id = @organization.id
    @organization.destroy!

    # Töröljük a szervezetek listázásának cache-ét és a specifikus szervezet cache-eit
    Rails.cache.delete_matched("organizations/#{organization_id}/*")
    Rails.cache.delete_matched("organizations/user_*/all")

    redirect_to organizations_url, notice: "Organization was successfully destroyed."
  end

  private

  def set_organization
    # Gyorsítótárazott lekérdezés egy szervezet adataihoz és kapcsolódó objektumaihoz
    @organization = Rails.cache.fetch("organizations/#{params[:id]}/details", expires_in: 5.minutes) do
      Organization.includes(
        :users,
        :owner,
        memberships: :user,
        projects: [ :project_manager, { tasks: [ :assignee, :reporter ] } ]
      ).find_by(id: params[:id])
    end

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
