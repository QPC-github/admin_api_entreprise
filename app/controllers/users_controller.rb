class UsersController < AuthenticatedUsersController
  before_action { authorize_user_resource_access!(user_resource_id) }

  def show
    @user = User.find(user_resource_id)
  end

  private

  def user_resource_id
    params[:id]
  end
end
