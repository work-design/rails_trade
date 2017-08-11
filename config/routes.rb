Rails.application.routes.draw do

  namespace :admin do

    get 'trade' => 'trade#index'
    resources :goods do
      get 'promote' => :edit_promote, on: :member
      patch 'promote' => :update_promote, on: :member
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

    resources :buyers do
      get :orders, on: :collection
      put :remind, on: :collection
    end
    resources :charges
    resources :orders, only: [:index, :show, :edit, :update, :destroy] do
      get :payments, on: :collection
      resources :order_payments
    end
    resources :payments do
      resources :payment_orders do
        post :batch, on: :collection
        patch :cancel, on: :member
      end
      get :dashboard, on: :collection
      patch :analyze, on: :member
      patch :adjust, on: :member
    end
    resources :refunds
    resources :payment_strategies
    resources :payment_methods do
      resources :payment_references, as: :references
      get :unverified, on: :collection
      patch :verify, on: :member
      patch :merge_from, on: :member
    end
  end

  namespace :my do
    resources :orders do
      patch :paypal_pay, on: :member
      get :alipay_pay, on: :member
      get :execute, on: :member
      get 'cancel' => :edit_cancel, on: :member
      put 'cancel' => :update_cancel, on: :member
      put :refund, on: :member
      get :check, on: :member
    end
  end

  resources :buyers do
    get :search, on: :collection
  end
  resources :payment_methods

  resources :payments, only: [:index] do
    get :result, on: :collection
  end

end
