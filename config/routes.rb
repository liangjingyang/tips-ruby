Rails.application.routes.draw do

  scope path: '/api', defaults: {format: :json} do
    scope path: '/v1' do
      namespace :admin do
        resources :boxes, only: [:index, :update] do
          put :approve, to: 'boxes#approve'
          put :switch, to: 'boxes#switch'
        end
        resources :recommends, only: [:index, :create, :update, :destroy]
        resources :posts, only: [:index]
      end

      
      resources :users, only: [:index, :show, :update] do
        get :uri_parser
      end
      get 'upload_res_token', to: 'users#upload_res_token'
      get :me, to: 'users#me'

      post 'sessions/userinfo', to: 'sessions#userinfo'
      get 'sessions/check', to: 'sessions#check'
      resources :sessions, only: [:create, :destroy]
      resources :boxes, only: [:create, :index, :update, :show, :destroy] do
        post :generate_qrcode_token
        put :switch, to: 'boxes#switch'
      end

      resources :posts, only: [:index]
      resources :recommends, only: [:index]

      get 'cart', to: 'orders#cart'
      post 'checkout', to: 'orders#checkout'
      put 'report', to: 'orders#report'
      get 'sell_orders', to: 'orders#sell_orders'

      resources :withdraws, only: [:create, :index] do
        delete 'cancel', to: 'withdraws#cancel'
      end

      get :wx_unified_order, to: 'wx#unified_order'
      post :wx_notify_unified_order, to: 'wx#notify_unified_order'
      post :wx_contact, to: 'wx#contact'

      get :server_config, to: 'users#server_config'

    end
  end
  
  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => '/sidekiq'
  Sidekiq::Web.use(Rack::Auth::Basic) { |user, pass| user == 'tech' && pass == 'Woshimima123' }
  Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

  match '*path', to: 'errors#route_not_found', via: :all
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
