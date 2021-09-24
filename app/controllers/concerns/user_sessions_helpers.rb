module UserSessionsHelpers
  extend ActiveSupport::Concern

  def current_user
    @current_user ||= session[:current_user_id] &&
      User.find(session[:current_user_id])
  end

  def user_signed_in?
    !current_user.nil?
  end

  def sign_in_and_redirect(user)
    session[:current_user_id] = user.id
    redirect_current_user_to_homepage
  end

  def redirect_current_user_to_homepage
    if current_user.admin?
      redirect_to admin_users_path
    else
      redirect_to user_path(current_user)
    end
  end
end
