class UserPolicy < ApplicationPolicy
  attr_reader :jwt_user

  def initialize(jwt_user, user_record)
    @jwt_user = jwt_user
    @user_record = user_record
  end

  def show?
    current_user?
  end

  def transfer_ownership?
    current_user?
  end

  private

  def current_user?
    jwt_user.id == @user_record.id
  end
end
