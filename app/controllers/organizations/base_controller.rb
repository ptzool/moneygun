class Organizations::BaseController < ApplicationController
  # the order of the before_actions is important
  before_action :set_organization
  # before_action :authorize_membership!
  before_action :set_current_membership
  # ensure Pundit "authorize" is called for every controller action
  # after_action :verify_authorized

  # def authorize_membership!
  #   redirect_to root_path, alert: "You are not authorized to perform this action." unless @organization.users.include?(current_user)
  #   raise Pundit::NotAuthorizedError unless @organization.users.include?(current_user)
  # end

  # def authorize_organization_admin!
  #   redirect_to organization_path(@organization), alert: "You are not authorized to perform this action." unless @current_membership.admin?
  #   raise Pundit::NotAuthorizedError unless @current_membership.admin?
  # end

  before_action :set_paper_trail_whodunnit

  def user_for_paper_trail
    @current_membership.id
  end

  def authorize_organization_owner!
    redirect_to organization_path(@organization), alert: "You are not authorized to perform this action." unless @organization.owner?(current_user)
  end

  private

  def set_organization
    begin
      organization_id = params[:organization_id]
      # Használjunk cache-elést az organization lekérdezéséhez
      @organization = Rails.cache.fetch("user_#{current_user.id}/organization_#{organization_id}", expires_in: 2.minutes) do
        current_user.organizations
                 .includes(:memberships, :owner)
                 .find(organization_id)
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to organizations_path, alert: "Organization not found."
    end
  end

  def set_current_membership
    membership_cache_key = "user_#{current_user.id}/organization_#{@organization.id}/membership"
    @current_membership ||= Rails.cache.fetch(membership_cache_key, expires_in: 5.minutes) do
      current_user.memberships.find_by(organization: @organization)
    end
  end

  def pundit_user
    @current_membership
  end
end
