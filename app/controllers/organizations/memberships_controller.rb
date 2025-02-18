class Organizations::MembershipsController < Organizations::BaseController
  before_action :set_membership, only: [ :edit, :update, :destroy ]
  before_action :set_default_breadcrumbs

  def index
    authorize Membership
    @memberships = @organization.memberships.includes(:user)
  end

  def new
    authorize @organization.memberships.new
    @form = MembershipInvitation.new(organization: @organization, role: Membership.roles[:employee])
  end

  def create
    authorize @organization.memberships.new
    @form = MembershipInvitation.new(email: params.dig(:membership_invitation, :email), role: params.dig(:membership_invitation, :role), organization: @organization, inviter: current_user)

    if @form.save
      redirect_to organization_memberships_path(@organization), notice: "#{@form.email} invited!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    add_breadcrumb @membership.user.full_name
  end

  def update
    if @membership.update(membership_params)
      redirect_to organization_memberships_path(@organization), notice: "User updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @membership.try_destroy
      respond_to do |format|
        if @membership.user == current_user
          format.turbo_stream { render turbo_stream: turbo_stream.remove(@membership) }
          format.html { redirect_to organizations_path, notice: "You have left that organization", status: :see_other }
        else
          format.turbo_stream { render turbo_stream: turbo_stream.remove(@membership) }
          format.html { redirect_to organization_memberships_path, notice: "User removed from organization", status: :see_other }
        end
      end
    else
      redirect_to organization_memberships_path(@organization), alert: "Failed to remove user from organization"
    end
  end

  private

  def set_membership
    @membership = @organization.memberships.find(params[:id])
    authorize @membership
  end

  def membership_params
    params.require(:membership).permit(:role)
  end

  def set_default_breadcrumbs
    add_breadcrumb "Home", :root_path
    add_breadcrumb "Organizations", :organizations_path
    add_breadcrumb @organization.name, organization_path(@organization)
    add_breadcrumb "Members", :organization_memberships_path
  end
end
