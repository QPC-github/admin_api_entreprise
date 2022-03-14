class JwtFacade
  attr_reader :jwt

  def initialize(jwt_id:)
    return if jwt_id.blank?

    @jwt = JwtAPIEntreprise.find(jwt_id)
  end

  def roles
    @jwt&.roles
  end

  def attestations_roles
    roles&.select { |r| attestations_codes.include? r.code }
  end

  private

  def attestations_codes
    %w[attestations_sociales attestations_fiscales]
  end
end
