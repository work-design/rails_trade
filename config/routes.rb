Rails.application.routes.draw do

  scope :admin, as: 'admin', module: 'the_trade_admin' do
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
    resources :promotes do
      get :search, on: :collection
      patch :toggle, on: :member
      patch :discount, on: :member
      patch :overall, on: :member
      resources :charges
    end
    resources :promote_buyers
    resources :promote_goods
    resources :providers
    resources :produces
    resources :areas

    resources :buyers do
      get :overdue, on: :collection
      get :orders, on: :member
      put :remind, on: :collection
    end
    resources :orders, only: [:index, :show, :edit, :update, :destroy] do
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
    resources :refunds do
      patch :confirm, on: :member
    end
    resources :payment_strategies
    resources :payment_methods do
      resources :payment_references, as: :references
      get :unverified, on: :collection
      patch :verify, on: :member
      patch :merge_from, on: :member
    end
  end

  scope :my, as: 'my', module: 'the_trade_my' do
    resource :buyer
    resource :provider
    resources :good_providers
    resources :orders do
      patch :paypal_pay, on: :member
      patch :stripe_pay, on: :member
      get :alipay_pay, on: :member
      get :execute, on: :member
      get 'cancel' => :edit_cancel, on: :member
      put 'cancel' => :update_cancel, on: :member
      put :refund, on: :member
      get :check, on: :member
    end
    resources :order_items
    resources :payment_methods
    resources :cart_items do
      get :total, on: :collection
    end
    resources :addresses
  end

  resources :areas, only: [] do
    get :search, on: :collection
  end
  resources :buyers, only: [] do
    get :search, on: :collection
  end
  resources :providers, only: [] do
    get :search, on: :collection
  end
  resources :payment_methods
  resources :payments, only: [:index] do
    get :result, on: :collection
    match :notify, on: :collection, via: [:get, :post]
  end

end
