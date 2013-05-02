Isg2::Application.routes.draw do
  root to: "node#index"

  match "node" => "node#index", via: [:get, :post]
  match "node/create" => "node#create", via: [:get, :post]
  match "node/edit" => "node#edit", via: [:get, :post]
  match "node/graphview" => "node#graphview", via: [:get]
  match "node/getData" => "node#getData", via: [:get]
  match "node/import" => "node#import", via: [:get, :post]
  delete "node/removeAll"
  delete "node/destroy"

  match "resource/create" => "resource#create", via: [:get, :post]
  match "resource/edit" => "resource#edit", via: [:get, :post]
  delete "resource/destroy"

  match "complaint/create" => "complaint#create", via: [:get, :post]
  delete "complaint/destroy"
  match "complaint" => "complaint#index", via: [:get, :post]
  match "complaint/ticket" => "complaint#ticket", via: [:get, :post]
  get "complaint/chart"
  get "complaint/getComplaintData"
  post "complaint/:id/update_status" => "complaint#update_status", as: :complaint_update_status

  get "logout" => "application#logout"

  match "admin" => "admin#index", via: :get
  match "admin/create" => "admin#create", via: [:get, :post]
  match "admin/destroy" => "admin#destroy", via: [:get, :post]
  
  match "message" => "message#index", via: [:get, :post]
  match "message/create" => "message#create", via: [:get, :post]
  match "message/:id/reply" => "message#reply", as: :message_reply, via: [:get, :post]
  match "message/destroy" => "message#destroy", via: [:get, :post]

  match "announcement" => "announcement#index", via: [:get, :post]
  match "announcement/create" => "announcement#create", via: [:get, :post]
  match "announcement/edit" => "announcement#edit", via: [:get, :post]
  match "announcement/notice" => "announcement#notice", via: [:get, :post]

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
