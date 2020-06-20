Rails.application.routes.draw do

  scope module: 'trade' do
    resources :payments, only: [:index] do
      get :result, on: :collection
      match :notify, on: :collection, via: [:get, :post]
      match :alipay_notify, on: :collection, via: [:get, :post]
      match :wxpay_notify, on: :collection, via: [:get, :post]
    end
    resources :buyers, only: [] do
      get :search, on: :collection
    end
  end

  scope :admin, module: 'trade/admin', as: :admin do
    get 'trade' => 'trade#index'

    resources :buyers do
      get :overdue, on: :collection
      get :orders, on: :member
      put :remind, on: :collection
    end
    resources :carts, except: [:new] do
      collection do
        get :total
        get :doc
        get :only
      end
    end
    resources :orders do
      collection do
        get :payments
        get :refresh
      end
      patch :refund, on: :member
      resources :order_payments
    end
    resources :trade_items
    resources :trade_promotes
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
      collection do
        get :unverified
        get :mine
      end
      member do
        patch :verify
        patch :merge_from
      end
    end
    resources :produces
    resources :promotes do
      get :search, on: :collection
      resources :promote_charges, as: 'charges'
    end
    resources :promote_charges, only: [] do
      get :options, on: :collection
    end
    resources :promote_buyers
    resources :promote_goods do
      get :goods, on: :collection
    end
    resources :refunds do
      patch :confirm, on: :member
      patch :deny, on: :member
    end
  end

  scope :my, module: 'trade/board', as: :my do
    resource :cart do
      get :add
    end
    resources :trade_items do
      member do
        patch :check
        patch :uncheck
      end
    end
    resources :good_providers
    resources :orders do
      collection do
        post :direct
        get :refresh
      end
      member do
        get :paypal_pay
        get :alipay_pay
        get :wxpay_pay
        get :wxpay_pc_pay
        patch :stripe_pay
        get :paypal_execute
        get :pay
        get 'payment_type' => :edit_payment_type
        get 'cancel' => :edit_cancel
        put 'cancel' => :update_cancel
        put :refund
        get :wait
      end
    end
    resources :payment_methods
  end

end
