Rails.application.routes.draw do
  devise_for :users

  resources :users
  resources :posts do
    resources :comments, except: %i(index)
    resources :likes, only: %i(index create destroy)
  end

  root to: 'posts#index'
end
