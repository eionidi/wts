Rails.application.routes.draw do
  get 'parser/yandex'

  resources :users
  resources :posts

  root to: 'users#index'
end
