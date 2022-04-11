class AttestationsController < AuthenticatedUsersController
  before_action :extract_token,  only: %i[new search]
  before_action :find_jwt_roles, only: %i[new search]

  def index; end

  def new
    return unless @jwt

    respond_to do |format|
      format.turbo_stream
    end
  end

  def search
    try_search
  # Faire heriter des erreurs dans les controller (meme une classe mère)
  rescue StandardError => e
    handle_error!(e)
  end

  private

  def try_search
    result = Siade.new(token: @jwt.rehash).entreprises(siret: params[:siret])

    @result = JSON.parse(result)

    set_attestations_url if @result

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def set_attestations_url
    set_attestation_sociale_url if @jwt_attestations_roles.map(&:code).include? 'attestations_sociales'
    set_attestation_fiscale_url if @jwt_attestations_roles.map(&:code).include? 'attestations_fiscales'
  end

  def set_attestation_sociale_url
    response = Siade.new(token: @jwt.rehash).attestations_sociales(siren: siren)

    @url_attestation_sociale = JSON.parse(response)['url']
  end

  def set_attestation_fiscale_url
    response = Siade.new(token: @jwt.rehash).attestations_fiscales(siren: siren)

    @url_attestation_fiscale = JSON.parse(response)['url']
  end

  def handle_error!(error)
    flash_message(:error, title: 'Erreur lors de la recherche', description: error.message)

    redirect_to profile_attestations_path
  end

  def extract_token
    return if params[:jwt_id].blank?

    @jwt = JwtAPIEntreprise.find(params[:jwt_id])
  end

  def find_jwt_roles
    @jwt_attestations_roles = @jwt.roles.select { |r| attestations_roles.include? r.code } if @jwt
  end

  def attestations_roles
    %w[attestations_sociales attestations_fiscales]
  end

  def siren
    params[:siret].first(9)
  end
end
