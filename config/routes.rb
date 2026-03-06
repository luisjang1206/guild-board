Rails.application.routes.draw do
  namespace :admin do
    root "dashboard#show"
    resources :users, only: [ :index, :show ]
  end
  get "/health", to: "health#show"
  resources :projects do
    resources :project_keys, only: [ :create, :destroy ] do
      member do
        patch :toggle_active
        post :regenerate
      end
    end
    resource :board, only: [ :show ]
    resources :tasks, except: [ :index ] do
      member { patch :move }
      resources :comments, only: [ :create ]
      resources :checklists, only: [ :create, :update, :destroy ]
    end
    resources :board_columns, only: [ :create, :update, :destroy ] do
      member { patch :move }
    end
    resources :labels
  end
  root "pages#home"
  resource :session
  resource :registration, only: %i[new create]
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
