Rails.application.routes.draw do
  # Devise routes for authentication
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  # Root path shows the URL shortening form
  root "urls#new"

  # URL resources for create and show operations
  resources :urls, only: [ :new, :create, :show ] do
    member do
      get "stats" # Adds /urls/:id/stats route
    end
  end

  # User dashboard to see all user's URLs
  get "dashboard", to: "users#dashboard", as: :user_dashboard

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # Short URL redirection (for example: /abc123). Declared last and constrained
  # to the Base62 alphabet so it cannot shadow any named route above it.
  get "/:shortened_path", to: "urls#redirect", as: :short,
      constraints: { shortened_path: /[0-9A-Za-z]+/ }
end
