Rails.application.routes.draw do
  scope RailsCom.default_routes_scope do
    concern :orderable do
      resource :lawful_wallet do
        get :account
      end
      resources :orders do
        collection do
          get 'cart/:current_cart_id' => :cart
          post :add
          post :trial
        end
        member do
          get :wait
          post :package
          get :pay
          get :payment_types
          get :payment_frozen
          get :payment_type
          get 'cancel' => :edit_cancel
          put 'cancel' => :update_cancel
          put :refund
          patch :cancel
          get :success
        end
        resources :packages
      end
      resources :items do
        collection do
          post :trial
        end
        member do
          get :promote
          patch :toggle
          post :finish
          post :untrial
          get :order_edit
          patch :order_update
        end
        resources :packageds
        resources :holds
      end
      resources :deliveries
      resources :carts, except: [:new, :create] do
        collection do
          get :list
          get :addresses
          get :promote
        end
        member do
          patch :toggle_all
        end
      end
      resources :promote_goods, only: [:index, :show]
      resources :card_templates do
        member do
          get :code
        end
      end
      resources :wallet_templates, only: [:index, :show] do
        collection do
          get :token
        end
      end
      resources :wallets, only: [:show] do
        resources :wallet_logs, only: [:index, :show]
      end
      resources :payments do
        collection do
          get 'order/:order_id' => :order_new
          post 'order/:order_id' => :order_create
          get 'payment_order/:payment_order_id' => :payment_order_new
          post 'payment_order/:payment_order_id' => :payment_order_create
          get 'wxpay/:order_id' => :wxpay
        end
      end
    end

    concern :order_admin do
      resources :orders do
        collection do
          get :payments
          get :refresh
          get 'cart/:current_cart_id' => :cart
          get 'user/:user_id' => :user
          get :unpaid
          delete :batch_destroy
          post :batch_paid
        end
        member do
          match :payment_types, via: [:get, :post]
          post :package
          post :micro
          get :print_data
          post :print
          get :payment_orders
          get :payment_new
          patch :payment_create
          delete :payment_destroy
          match :adjust_edit, via: [:get, :post]
          patch :adjust_update
        end
        resources :order_payments do
          collection do
            post :confirm
          end
        end
      end
      resources :payments do
        collection do
          get :dashboard
        end
        member do
          patch :analyze
          patch :adjust
        end
        resources :refunds, only: [:new, :create]
        resources :payment_orders do
          collection do
            post :confirmable
          end
          member do
            post :confirm
            post :cancel
            post :refund
          end
        end
      end
      resources :scan_payments
      resources :items do
        collection do
          post :trial
        end
        member do
          get :carts
          patch :toggle
          patch :compute
          post :print
          get :promote
          post :finish
          post :untrial
        end
        resources :holds
      end
    end

    namespace :trade, defaults: { business: 'trade' } do
      resources :payments, only: [:index] do
        collection do
          get :result
          match :notify, via: [:get, :post]
          match :alipay_notify, via: [:get, :post]
          match 'wxpay_notify/:mch_id' => :wxpay_notify, via: [:get, :post]
        end
      end
      resources :card_templates do
        resources :advances
      end
      resources :orders, only: [] do
        member do
          get :qrcode
        end
      end
      resources :items, only: [] do
        collection do
          get :chart
          get :month
        end
      end

      namespace :panel, defaults: { namespace: 'panel' } do
        root 'home#index'
        concerns :order_admin
        resources :exchange_rates
        resources :units
        resources :items do
          member do
            get :carts
          end
        end
      end

      namespace :admin, defaults: { namespace: 'admin' } do
        root 'home#index'
        concerns :order_admin
        resources :carts, except: [:new] do
          collection do
            get :total
            get :doc
            get :only
            get :member_organ
            get :member
            get :user
            get 'user/:user_id' => :user_show
          end
          resources :promote_good_users do
            collection do
              post :user_search
              post :good_search
              get :user
            end
          end
        end
        resources :cart_promotes
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
        resources :additions do
          resources :addition_charges
        end
        scope path: ':rentable_type/:rentable_id' do
          resource :rentable
          resources :rent_charges do
            member do
              get :wallet
              patch 'wallet' => :update_wallet
            end
          end
        end
        resources :promotes do
          collection do
            get :search
          end
          resources :promote_charges
          resources :promote_good_types do
            collection do
              get :part_new
              post :part_create
              get :part
              post :search
            end
            member do
              get :blacklist
              get :blacklist_new
              post :blacklist_create
            end
          end
        end
        resources :promote_charges, only: [] do
          collection do
            get :options
          end
        end
        resources :promote_goods do
          resources :item_promotes
        end
        resources :refunds, except: [:new, :create] do
          member do
            patch :confirm
            patch :deny
          end
        end
        resources :card_templates do
          collection do
            get :advance_options
          end
          resources :purchases
          resources :privileges do
            member do
              patch :reorder
            end
          end
          resources :card_promotes
          resources :cards do
            resources :card_purchases
          end
        end
        resources :lawful_advances do
          collection do
            get :lawful
          end
        end
        resources :wallet_templates do
          resources :advances
          resources :custom_wallets
          resources :wallet_prepayments
          resources :wallet_goods
        end
        resources :lawful_wallets
        resources :wallets, only: [] do
          resources :wallet_payments
          resources :wallet_advances
          resources :wallet_logs
          resources :wallet_sells
          resources :payouts do
            member do
              put :do_pay
            end
          end
        end
      end

      namespace :in, defaults: { namespace: 'in' } do
        resources :orders, only: [] do
          collection do
            delete :batch_destroy
            post :batch_paid
          end
          resources :order_payments
        end
        concerns :orderable
      end

      namespace :my, defaults: { namespace: 'my' } do
        concerns :orderable
        resources :wxpay_payments, only: [:index, :new, :create, :show] do
          collection do
            get :qrcode
          end
        end
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
        end
        resources :payouts, only: [:index, :create] do
          collection do
            get :list
          end
        end
      end

      namespace :agent, defaults: { namespace: 'agent' } do
        concerns :order_admin
        resources :carts
      end

      namespace :me, defaults: { namespace: 'me' } do
        concerns :orderable
        controller :home do
          get :qrcode
        end
      end

      namespace :our, defaults: { namespace: 'our' } do
        concerns :orderable
      end

      namespace :mem, defaults: { namespace: 'mem' } do
        concerns :orderable
      end

      namespace :from, defaults: { namespace: 'from' } do
        concerns :orderable
      end

      namespace :board, defaults: { namespace: 'board' } do
        concerns :orderable
      end
    end
  end
  resolve 'Trade::Purchase' do |purchase|
    url_for(controller: 'trade/my/card_templates', action: 'show', id: purchase.card_template_id, return_state: StateUtil.encode(request))
  end
  resolve 'Trade::Advance' do |advance|
    if advance.wallet_template_id
      url_for(controller: 'trade/my/wallet_templates', action: 'show', id: advance.wallet_template_id, return_state: StateUtil.encode(request))
    else
      url_for(controller: 'trade/my/lawful_wallets', action: 'show', return_state: StateUtil.encode(request))
    end
  end
end
