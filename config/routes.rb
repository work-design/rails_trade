Rails.application.routes.draw do

  namespace :admin do

    get 'trade' => 'trade#index'

    resources :goods do
      get 'pic' => :edit_pic, :on => :member
      patch 'pic' => :update_pic, :on => :member
      get 'items' => :edit_items, :on => :member
      patch 'items' => :update_items, :on => :member
      get 'taxons' => :edit_taxons, :on => :member
      patch 'taxons' => :update_taxons, :on => :member
      get 'promote' => :edit_promote, :on => :member
      patch 'promote' => :update_promote, :on => :member
      resources :good_items
      resources :sales
    end
    resources :invites
    resources :races do
      resources :crowds, :shallow => true
    end
    resources :taxons
    resources :promotes
    resources :providers
    resources :produces
    resources :carts, :only => [:index, :destroy]
    resources :areas

    resources :orders, only: [:index, :show, :edit, :update, :destroy] do
      get :payments, on: :collection
    end
    resources :payments do
      resources :payment_orders
      get :dashboard, on: :collection
      patch 'analyze', on: :member
    end
    resources :payment_methods do
      resources :payment_references, as: :references
      get :unverified, on: :collection
      patch :verify, on: :member
      patch :merge_from, on: :member
    end
  end

  namespace :my do
    resources :orders do
      patch :pay, on: :member
      get :execute, on: :member
      get :cancel, on: :member
      get :check, on: :member
    end
  end

  resources :buyers do
    get :search, on: :collection
    resources :payment_methods
  end

  resources :orders, only: [] do
    get :paypal_result, on: :collection
  end

end
