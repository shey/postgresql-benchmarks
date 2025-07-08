Rails.application.routes.draw do
  get "up" => "rails/health#show", :as => :rails_health_check

  resources :sensors, only: [:index, :show] do
    member do
      get :stats
      get :failures
      get :history
    end

    resources :pings, only: [:index, :create]
  end

  namespace :metrics do
    get "failures/top", to: "failures#top"
  end
end
