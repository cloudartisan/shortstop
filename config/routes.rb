Rails.application.routes.draw do
  # Root path shows the URL shortening form
  root 'urls#new'
  
  # URL resources for create and show operations
  resources :urls, only: [:new, :create, :show]
  
  # Short URL redirection (for example: /abc123)
  get '/:shortened_path', to: 'urls#redirect', as: :short
  
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check
end
