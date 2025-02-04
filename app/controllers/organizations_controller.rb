class OrganizationsController < ApplicationController
  before_action :set_organization, only: %i[show edit update destroy]
  before_action :set_default_breadcrumbs

  def index
    @organizations = current_user.organizations.includes(:users)
  end

  def show
    add_breadcrumb @organization.name, organization_path(@organization), only: %i[show]
  end

  def new
    add_breadcrumb "New Organization", :new_organization_path, only: %i[new create]
    @organization = Organization.new
  end

  def edit
  end

  def create
    @organization = Organization.new(organization_params)
    @organization.owner = current_user
    @organization.memberships.build(user: current_user, role: Membership.roles[:admin])

    if @organization.save
      redirect_to organization_url(@organization), notice: "Organization was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @organization.update(organization_params)
      redirect_to organization_url(@organization), notice: "Organization was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @organization.destroy!

    redirect_to organizations_url, notice: "Organization was successfully destroyed."
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
    @current_membership ||= current_user.memberships.find_by(organization: @organization)
    authorize @organization

  rescue ActiveRecord::RecordNotFound
    redirect_to organizations_path()
  end

  def organization_params
    params.require(:organization).permit(:name, :logo, :address, :email, :registration_number, :tax_number, :iban)
  end

  def set_default_breadcrumbs
    add_breadcrumb "Home", :root_path
    add_breadcrumb "Organizations", :organizations_path
  end
end
