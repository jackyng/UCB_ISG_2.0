Isg2::Application.routes.draw do
  root to: "node#index"

  get "node" => "node#index"
  match "node/create" => "node#create", via: [:get, :post]
  match "node/edit" => "node#edit", via: [:get, :post]
  match "node/graphview" => "node#graphview", via: [:get]
  match "node/getData" => "node#getData", via: [:get]
  match "node/import" => "node#import", via: [:get, :post]
  post "/node/paste"
  delete "node/removeAll"
  delete "node/destroy"

  match "resource/create" => "resource#create", via: [:get, :post]
  match "resource/edit" => "resource#edit", via: [:get, :post]
  delete "resource/destroy"
  get "resource/:id/open" => "resource#open", as: :resource_open

  get "complaint" => "complaint#index"
  match "complaint/create" => "complaint#create", via: [:get, :post]
  delete "complaint/destroy"
  match "complaint/ticket" => "complaint#ticket", via: [:get, :post]
  get "complaint/chart"
  get "complaint/getComplaintData"
  post "complaint/:id/update_status" => "complaint#update_status", as: :complaint_update_status

  get "logout" => "application#logout"

  get "admin" => "admin#index"
  match "admin/create" => "admin#create", via: [:get, :post]
  match "admin/destroy" => "admin#destroy", via: [:get, :post]
  
  match "message" => "message#index", via: [:get, :post]
  match "message/create" => "message#create", via: [:get, :post]
  match "message/:id/reply" => "message#reply", as: :message_reply, via: [:get, :post]
  match "message/destroy" => "message#destroy", via: [:get, :post]

  get "announcement" => "announcement#index"
  get "announcement/:id/notice" => "announcement#notice"
  match "announcement/create" => "announcement#create", via: [:get, :post]
  match "announcement/:id/edit" => "announcement#edit", via: [:get, :post], as: :announcement_edit
  delete "announcement/:id/destroy" => "announcement#destroy", as: :announcement_destroy
  match "announcement/notice" => "announcement#notice", via: [:get, :post]
  post "announcement/:id/toggle_show" => "announcement#toggle_show", as: :announcement_toggle_show

  get "query" => "query#index"
  match "query/create" => "query#create", via: [:get, :post]
  delete "query/:id/destroy" => "query#destroy", as: :query_destroy
  match "query/:id/edit" => "query#edit", as: :query_edit, via: [:get, :post]
  match "query/run" => "query#run", as: :query_run, via: [:get, :post]
end
