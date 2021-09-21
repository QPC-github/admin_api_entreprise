class OAuthAPIGouvLoginsController < ApplicationController
  def new
  end

  def create
    if @user = User.find_by_email(authenticated_user_email)
      create_login_cookie
      redirect_to_user_homepage
    else
      redirect_to login_path
    end
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end

  def authenticated_user_email
    auth_hash.try('info').try('email')
  end

  def create_login_cookie
    cookies[:current_user_id] = @user.id
  end

  def redirect_to_user_homepage
    if @user.admin?
      redirect_to users_path
    else
      redirect_to user_path(@user)
    end
  end
end
