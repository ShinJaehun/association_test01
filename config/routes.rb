Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  resources :posts
  resources :books do
    resources :posts, module: :books
  end

  resources :users, only:[:show]

  root 'posts#index'
end
