Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [] do
        resources :cars, only: [:index], defaults: {format: :json}
      end
    end
  end
end
