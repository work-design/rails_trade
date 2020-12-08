Rails.application.routes.draw do

  scope module: 'trade', defaults: { business: 'trade' } do
    resources :payments, only: [:index] do
      collection do
        get :result
        match :notify, via: [:get, :post]
        match :alipay_notify, via: [:get, :post]
        match :wxpay_notify, via: [:get, :post]
      end
    end
    resources :card_templates do
      resources :advances
    end
  end

  scope :admin, module: 'trade/admin', as: :admin, defaults: { namespace: 'admin', business: 'trade' } do
    get 'trade' => 'trade#index'

    resources :users do
      collection do
        get :overdue
        put :remind
      end
      member do
        get :orders
      end
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
      member do
        patch :refund
      end
      resources :order_payments
    end
    resources :trade_items
    resources :trade_promotes
    resources :payments do
      collection do
        get :dashboard
      end
      member do
        patch :analyze
        patch :adjust
      end
      resources :payment_orders do
        member do
          patch :cancel
        end
      end
    end
    resources :payment_strategies
    resources :payment_methods do
      collection do
        get :unverified
        get :mine
      end
      member do
        patch :verify
        patch :merge_from
      end
      resources :payment_references, as: :references
    end
    resources :produces
    resources :promotes do
      collection do
        get :search
      end
      resources :promote_charges, as: 'charges'
    end
    resources :promote_charges, only: [] do
      collection do
        get :options
      end
    end
    resources :promote_carts
    resources :promote_goods do
      collection do
        get :goods
      end
    end
    resources :refunds do
      member do
        patch :confirm
        patch :deny
      end
    end
    resources :card_templates do
      collection do
        get :advance_options
        get :add_item
        get :remove_item
      end
      resources :advances
      resources :card_promotes
    end
    resources :cards do
      resources :card_logs
      resources :card_advances
    end
    resources :cashes
    resources :cash_givens
    resources :payouts do
      member do
        put :do_pay
      end
    end
    resources :cash_logs
  end

  scope :my, module: 'trade/my', as: :my, defaults: { namespace: 'my', business: 'trade' } do
    resource :cart do
      match :add, via: [:get, :post]
    end
    resources :trade_items do
      member do
        patch :toggle
        get :promote
      end
    end
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
        get :payment_types
        get 'payment_type' => :edit_payment_type
        get 'cancel' => :edit_cancel
        put 'cancel' => :update_cancel
        put :refund
        get :wait
      end
    end
    resources :payments
    resources :payment_methods
    resources :advances do
      member do
        get :order
      end
    end
    resources :carts
    resources :card_logs, only: [:index]
    resources :cash_logs, only: [:index]
    resources :payouts, only: [:index, :create] do
      collection do
        get :list
      end
    end
  end

end
