Rails.application.routes.draw do
  get "up" => "rails/health#show", :as => :rails_health_check

  resources :sensors, only: [:index, :show] do
    member do
      get :failure_rate           # /sensors/:id/failure_rate
      get :recent_failures        # /sensors/:id/recent_failures
      get :hourly_stats           # /sensors/:id/hourly_stats
    end
  end

  resources :pings, only: [:create]  # POST /pings
end
