Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  resources :posts

  resources :books do
    resources :posts, module: :books
  end

  resources :messages do
    resources :posts, module: :messages
  end

  resources :users, only:[:show]
  resources :groups

  root 'posts#index'
  post 'add_user_to_group/:id', to: 'groups#add_user_to_group', as: 'add_user_to_group'
  delete 'remove_user_from_group/:id', to: 'groups#remove_user_from_group', as: 'remove_user_from_group'
end
