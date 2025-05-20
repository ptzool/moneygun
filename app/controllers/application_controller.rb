class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  
  # Handle ActiveStorage errors gracefully
  rescue_from ActiveStorage::FileNotFoundError, with: :handle_activestorage_error
  rescue_from ActiveStorage::IntegrityError, with: :handle_activestorage_error

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || organizations_path
  end

  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
  
  def handle_activestorage_error(exception)
    Rails.logger.error "ActiveStorage error: #{exception.message}"
    flash[:alert] = "There was a problem with the file operation. Please try again."
    redirect_to(request.referrer || root_path)
  end

  def current_organization
    @current_membership&.organization
  end

  helper_method :current_organization
end
