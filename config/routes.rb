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
  post 'join_group/:id', to: 'groups#join_group', as: 'join_group'
  delete 'leave_group/:id', to: 'groups#leave_group', as: 'leave_group'
end
