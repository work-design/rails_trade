Rails.application.routes.draw do

  scope :admin, as: 'admin', module: 'the_trade_admin' do
    get 'trade' => 'trade#index'
    resources :addresses
    resources :areas
    resources :buyers do
      get :overdue, on: :collection
      get :orders, on: :member
      put :remind, on: :collection
    end
    resources :cart_items, except: [:new] do
      get :total, on: :collection
      get :doc, on: :collection
      resources :cart_item_serves do
        post :add, on: :collection
      end
    end
    resources :orders do
      get :payments, on: :collection
      resources :order_payments
    end
    resources :payments do
      resources :payment_orders do
        patch :cancel, on: :member
      end
      get :dashboard, on: :collection
      patch :analyze, on: :member
      patch :adjust, on: :member
    end
    resources :payment_strategies
    resources :payment_methods do
      resources :payment_references, as: :references
      get :unverified, on: :collection
      patch :verify, on: :member
      patch :merge_from, on: :member
    end
    resources :produces
    resources :promotes do
      get :search, on: :collection
      patch :toggle, on: :member
      patch :overall, on: :member
      patch :contain, on: :member
      resources :promote_charges, as: 'charges'
    end
    resources :promote_buyers
    resources :promote_goods
    resources :providers

    resources :refunds do
      patch :confirm, on: :member
    end
    resources :serves do
      get :search, on: :collection
      patch :toggle, on: :member
      patch :overall, on: :member
      patch :contain, on: :member
      patch :default, on: :member
      resources :serve_charges, as: 'charges'
    end
  end

  scope :my, as: 'my', module: 'the_trade_my' do
    resource :buyer
    resource :provider

    resources :addresses
    resources :buyers, only: [] do
      get :search, on: :collection
    end
    resources :cart_items do
      get :total, on: :collection
    end
    resources :good_providers
    resources :orders do
      patch :balance_pay, on: :member
      patch :paypal_pay, on: :member
      patch :stripe_pay, on: :member
      get :alipay_pay, on: :member
      get :execute, on: :member
      get :pay, on: :member
      get 'payment_type' => :edit_payment_type, on: :member
      put 'payment_type' => :update_payment_type, on: :member
      get 'cancel' => :edit_cancel, on: :member
      put 'cancel' => :update_cancel, on: :member
      put :refund, on: :member
      get :check, on: :member
    end
    resources :order_items
    resources :payment_methods
  end

  resources :areas, only: [] do
    get :search, on: :collection
  end
  resources :payments, only: [:index] do
    get :result, on: :collection
    match :notify, on: :collection, via: [:get, :post]
    match :alipay_notify, on: :collection, via: [:get, :post]
  end
  resources :payment_methods
  resources :providers, only: [] do
    get :search, on: :collection
  end

end
