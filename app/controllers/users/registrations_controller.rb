class Users::RegistrationsController < Devise::RegistrationsController
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_user_registration_url, alert: "Try again later." }

  private

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password)
  end
end
