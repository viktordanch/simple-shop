Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # namespace :my_shop_b do
    root 'index#landing'
    get '/about_us', to: 'index#about_us'
    get '/contact_us', to: 'index#contact_us'
    get '/term_of_use', to: 'index#term_of_use'
    resources :orders, only: [:index, :create]
    resources :cart, only: [:index] do
      post '/add_product', to: 'cart#add_product', on: :collection
      post '/update_product_count', to: 'cart#update_product_count', on: :collection
    end

    resources :products, only: [:index, :show] do
      get '/list', to: 'products#list', on: :collection
      get '/product_by_page', to: 'products#product_by_page', on: :collection
    end
  # end
  devise_for :users, controllers: { sessions: 'sessions',
                                    registrations: 'registrations',
                                    confirmations: 'confirmations',
                                    passwords: 'passwords' }
end
