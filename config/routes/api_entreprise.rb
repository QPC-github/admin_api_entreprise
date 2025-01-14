constraints(APIEntrepriseDomainConstraint.new) do
  namespace :api do
    post '/datapass/api_entreprise/webhook' => 'datapass_webhooks#api_entreprise'
    post '/datapass/api_particulier/webhook' => 'datapass_webhooks#api_particulier'

    scope '/admin' do
      post '/datapass/webhook' => 'datapass_webhooks#api_entreprise'
    end
  end

  scope module: :api_entreprise do
    root to: redirect('/compte/se-connecter'), as: :dashboard_root, constraints: { subdomain: 'dashboard.entreprise.api' }
    root to: 'pages#home'

    get '/stats', to: 'stats#index'

    get '/compte/se-connecter', to: 'sessions#new', as: :login
    get '/compte/se-connecter/lien-magique', to: 'sessions#create_from_magic_link', as: :login_magic_link
    get '/auth/api_gouv/callback', to: 'sessions#create_from_oauth'
    get '/auth/failure', to: 'sessions#failure'
    delete '/compte/deconnexion', to: 'sessions#destroy', as: :logout

    get '/compte', to: 'users#profile', as: :user_profile

    get '/compte/demandes', to: 'authorization_requests#index', as: :authorization_requests

    get '/compte/telecharcher-documents', to: 'attestations#index', as: :attestations
    post '/compte/telecharcher-documents/rechercher-siret', to: 'attestations#search', as: :search_attestations

    get '/compte/jetons', to: 'tokens#index', as: :user_tokens
    post '/compte/jetons/:id/partager', to: 'restricted_token_magic_links#create', as: :token_create_magic_link
    get '/compte/jetons/:id/stats', to: 'tokens#stats', as: :token_stats
    get '/compte/jetons/:id', to: 'tokens#show', as: :token
    get '/compte/jetons/:id/renew', to: 'tokens#renew', as: :token_renew
    get '/compte/jetons/:id/contacts', to: 'contacts#index', as: :token_contacts

    post 'public/magic_link/create', to: 'public_token_magic_links#create'
    get 'public/jetons/:access_token', to: 'public_token_magic_links#show', as: :token_show_magic_link

    get '/compte/transferer', to: 'transfer_user_account#new', as: :transfer_account
    post '/compte/transferer', to: 'transfer_user_account#create'

    get '/catalogue', as: :endpoints, to: 'endpoints#index'
    get '/catalogue/*uid/exemple', as: :endpoint_example, to: 'endpoints#example'
    get '/catalogue/*uid', as: :endpoint, to: 'endpoints#show'

    get '/faq', to: 'faq#index', as: :faq_index
    get '/developpeurs', to: 'documentation#developers', as: :developers
    get '/developpeurs/guide-migration', to: 'documentation#guide_migration', as: :guide_migration
    get '/developpeurs/openapi', to: 'pages#redoc', as: :developers_openapi
    get '/cas_usages', to: 'cas_usages#index'
    get '/cas_usages/:uid', to: 'cas_usages#show', as: :cas_usage

    get '/blog/:id', to: 'blog_posts#show', as: :blog_post

    get '/apis/status', to: 'pages#current_status', as: :current_status
    get '/v3/openapi.yaml', to: ->(env) { [200, {}, [OpenAPIDefinition.instance.open_api_definition_content]] }, as: :openapi_definition

    get '/infolettre', to: 'pages#newsletter', as: :newsletter
    get '/mentions-legales', to: 'pages#mentions', as: :mentions
    get '/cgu', to: 'pages#cgu', as: :cgu
    get '/accessibilite', to: 'pages#accessibility', as: :accessibilite
  end
end
