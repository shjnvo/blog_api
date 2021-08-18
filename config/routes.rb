Rails.application.routes.draw do
  namespace :v1 do
    post 'login', to: 'sessions#create'
    delete 'logout', to: 'sessions#destroy'
    resources :users, except: :show do
      member do
        patch :lock
        patch :unlock
      end
    end
    resources :blogs do
      get :most_like_blog, on: :collection
      get :top_5_blogs, on: :collection
      member do
        post :like
        patch :unpublish
      end
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
