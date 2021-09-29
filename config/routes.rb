Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => '/api/admin/sidekiq'

  namespace :api do
    scope '/admin' do
      # Authentication
      get  '/oauth_api_gouv/login'      => 'oauth_api_gouv#login'

      #roles
      get  '/roles' => 'roles#index'
      post '/roles' => 'roles#create'

      # users
      get    '/users'                            => 'users#index'
      get    '/users/:id'                        => 'users#show'
      patch  '/users/:id'                        => 'users#update'
      delete '/users/:id'                        => 'users#destroy'
      post   '/users/:id/transfer_ownership'     => 'users#transfer_ownership'

      # jwt_api_entreprise
      get   '/jwt_api_entreprise'                       => 'jwt_api_entreprise#index'
      patch '/jwt_api_entreprise/:id'                   => 'jwt_api_entreprise#update'
      post  '/jwt_api_entreprise/:id/create_magic_link' => 'jwt_api_entreprise#create_magic_link'
      get   '/jwt_api_entreprise/show_magic_link'       => 'jwt_api_entreprise#show_magic_link'

      # datapass webhook
      post '/datapass/webhook' => 'datapass_webhooks#create'

      # private_metrics
      get '/private_metrics' => 'private_metrics#index'
    end
  end

  root to: redirect('/login')

  # Authentication
  get '/login', to: 'sessions#new'
  post '/auth/api_gouv', as: :login_api_gouv
  match '/auth/api_gouv/callback', to: 'sessions#create', via: [:get, :post]
  get '/auth/failure', to: 'sessions#failure'

  resources :users, only: %i[show] do
    resources :jwt_api_entreprise, only: %i[index]
  end

  namespace :admin do
    resources :users, only: %i[index]
  end
end
