Rails.application.routes.draw do
  get "up" => "rails/health#show", :as => :rails_health_check

  resources :sensors, only: [:index, :show] do
    member do
      get :stats        # e.g. uptime %, avg latency
      get :failures     # recent 5xx pings
      get :top_failures
    end

    resources :pings, only: [:index, :create]
  end
end
