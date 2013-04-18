Isg2::Application.routes.draw do
  root :to => "node#index"

  match "node" => "node#index", :via => [:get, :post]
  match "node/create" => "node#create", :via => [:get, :post]
  match "node/graphview" => "node#graphview", :via => [:get]
  get "node/destroy"

  match "resource/create" => "resource#create", :via => [:get, :post]
  get "resource/destroy"

  get "user/logout"

  match "complaint/create" => "complaint#create", :via => [:get, :post]
  get "complaint/destroy"
  match "complaint" => "complaint#index", :via => [:get, :post]
  match "complaint/ticket" => "complaint#ticket", :via => [:get, :post]
  match "complaint/chart" => "complaint#chart", :via => [:get]
  match "complaint/getComplaintData" => "complaint#getComplaintData", :via => [:get]

  resources :complaint do
    put 'toggle', :on => :member
  end

  match "user" => "user#index", :via => [:get, :post]

  resources :user do
    put 'toggle_admin', :on => :member
  end
  

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
