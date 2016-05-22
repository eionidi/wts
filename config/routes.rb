Rails.application.routes.draw do
  get 'parser/yandex'

  resources :users

  root to: 'users#index'
end
