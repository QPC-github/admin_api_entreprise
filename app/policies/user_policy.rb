class UserPolicy < ApplicationPolicy
  attr_reader :jwt_user

  def initialize(jwt_user, user_record)
    @jwt_user = jwt_user
    @user_record = user_record
  end

  def show?
    admin? || current_user?
  end

  def transfer_ownership?
    admin? || current_user?
  end

  def any_token_with_attestation_role?
    jwt_user.jwt_api_entreprise.flat_map { |jwt| jwt.decorate.attestations_roles }.any?
  end

  private

  def admin?
    jwt_user.admin?
  end

  def current_user?
    jwt_user.id == @user_record.id
  end
end
