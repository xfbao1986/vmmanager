Vmmanager::Application.routes.draw do

  resources :shutdown_requests

  devise_for :users, :skip => [:sessions, :registration, :password], :controllers => { :omniauth_callbacks => "omniauth_callbacks"}
  as :user do
    delete 'logout' => "devise/sessions#destroy", :as => :destroy_user_session
    delete 'delete' => "devise/registations#destroy", :as => :destroy_user
  end

  resources :vms do
    member do
      get 'continue_using' => 'vms#continue_using'
      get 'stop_using' => 'vms#stop_using'
      delete 'delete_from_xcp' => 'vms#delete_from_xcp'
      delete 'delete_dns_record' => 'vms#delete_dns_record'
      post 'shutdown' => 'vms#shutdown'
      post 'reboot' => 'vms#reboot'
    end
    collection do
      post 'info/:hostname' => 'vms#info', defaults: { format: 'json' }
      get 'xcp_search'
      get 'search'
      post 'shutdown_deletable' => 'vms#shutdown_deletable_vms'
    end
  end

  resources :pools, only: [:index, :show] do
    resources :hosts
  end

  resource :dns, only: [:create, :show, :destroy] do
    get 'search'
    get 'record_search'
  end

  resources :destroy_vm_requests do
    member do
      post 'execute' => 'destroy_vm_requests#execute'
    end
  end

  resources :dns_record_requests

  resources :users

  resources :setups

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root to: 'setups#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
