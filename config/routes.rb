Rails.application.routes.draw do

  namespace :trade, defaults: { business: 'trade' } do
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

    namespace :panel, defaults: { namespace: 'panel' } do
      resources :exchange_rates
    end

    namespace :admin, defaults: { namespace: 'admin' } do
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
      resources :promote_carts do
        collection do
          post :search
        end
      end
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
        end
        resources :advances
        resources :purchases
        resources :privileges do
          member do
            patch :reorder
          end
        end
        resources :card_promotes
        resources :card_prepayments
      end
      resources :cards do
        resources :card_logs
        resources :card_purchases
        resources :card_payments
      end
      resources :wallet_templates
      resources :wallets do
        resources :wallet_advances
        resources :wallet_logs
      end
      resources :payouts do
        member do
          put :do_pay
        end
      end
    end

    namespace :my, defaults: { namespace: 'my' } do
      resource :cart do
        match :add, via: [:get, :post]
        get :list
        post :current
        get :addresses
        get :promote
      end
      resource :wallet
      resources :wallet_logs, only: [:index]
      resources :promote_carts
      resources :trade_items do
        member do
          patch :toggle
          get :promote
        end
      end
      resources :orders do
        collection do
          match :add, via: [:get, :post]
          post :direct
          get :refresh
        end
        member do
          get :paypal_pay
          get :alipay_pay
          get :wxpay_pay
          get :wxpay_pc_pay
          get :wait
          patch :stripe_pay
          get :paypal_execute
          get :pay
          get :payment_types
          get 'payment_type' => :edit_payment_type
          get 'cancel' => :edit_cancel
          put 'cancel' => :update_cancel
          put :refund
          patch :cancel
          get :success
        end
      end
      resources :payments
      resources :payment_methods
      resources :advances do
        member do
          get :order
        end
      end
      resources :cards do
        collection do
          get :token
        end
        resources :card_purchases
        resources :card_logs, only: [:index]
      end
      resources :card_templates do
        member do
          get :code
        end
      end
      resources :payouts, only: [:index, :create] do
        collection do
          get :list
        end
      end
    end
  end

end
