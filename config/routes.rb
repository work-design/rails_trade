Rails.application.routes.draw do
  scope RailsCom.default_routes_scope do
    concern :orderable do
      resource :lawful_wallet do
        get :account
      end
      resources :orders do
        collection do
          get 'cart/:current_cart_id' => :cart
          post 'cart/:current_cart_id' => :cart_create
          post :add
          post :trial
        end
        member do
          get :wait
          post :package
          get :pay
          match :payment_types, via: [:get, :post]
          post :payment_pending
          post :payment_confirm
          get :payment_frozen
          get :payment_type
          get 'cancel' => :edit_cancel
          put 'cancel' => :update_cancel
          put :refund
          patch :cancel
          get :success
        end
        resources :packages
        resources :items, controller: 'order/items'
      end
      resources :items do
        collection do
          post :trial
          post :remove
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
          get :admin
          patch :toggle_all
        end
      end
      resources :promote_goods, only: [:index, :show]
      resources :card_templates, except: [:edit, :destroy] do
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
        member do
          post :print
        end
        resources :refunds, only: [:new, :create]
      end
    end

    concern :order_admin do
      resources :orders do
        collection do
          get :payments
          get :refresh
          get 'cart/:current_cart_id' => :cart
          post 'cart/:current_cart_id' => :cart_create
          get 'user/:user_id' => :user
          get :unpaid
          delete :batch_destroy
          get :new_simple
        end
        member do
          match :payment_types, via: [:get, :post]
          post :payment_pending
          post :payment_confirm
          post :package
          post :micro
          get :print_data
          post :print
          get :payment_orders
          get :payment_new
          get :purchase
          patch :payment_create
          delete :payment_destroy
          match :adjust_edit, via: [:get, :post]
          patch :adjust_update
          match :desk_edit, via: [:get, :post]
          patch :desk_update
          match :contact_edit, via: [:get, :post]
        end
        resources :order_payments do
          collection do
            match :new_micro, via: [:get, :post]
            post :confirm
          end
        end
      end
      resources :payments do
        collection do
          get :dashboard
          get :uncheck
          post :confirm
        end
        member do
          patch :analyze
          patch :adjust
          post :print
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
      resources :scan_payments do
        collection do
          post :batch
          post 'desk/:desk_id' => :desk
        end
      end
      resources :hand_payments do
        collection do
          post :batch
          post 'desk/:desk_id' => :desk
        end
      end
      resources :items do
        collection do
          get :purchase
          get :produce
          post :trial
          post :batch_purchase
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
      resources :refunds, except: [:new, :create] do
        member do
          patch :confirm
          patch :deny
        end
      end
      resources :desks, only: [] do
        resources :orders, controller: 'desk/orders' do
          collection do
            get :history
            post :done
          end
        end
        resources :items, controller: 'desk/items'
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
        controller :home do
          post :good_search
          post :part_search
        end
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
          resources :promote_goods, controller: 'cart/promote_goods' do
            collection do
              post :user_search
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
          resources :promote_goods do
            collection do
              match :part_new, via: [:get, :post]
              post :part_create
              get :part
            end
            member do
              get :blacklist
              match :blacklist_new, via: [:get, :post]
              post :blacklist_create
            end
            resources :item_promotes
          end
        end
        resources :promote_charges, only: [] do
          collection do
            get :options
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
          resources :promote_goods, controller: 'card_template/promote_goods'
          resources :cards do
            resources :card_purchases
            resources :promote_goods, controller: 'card/promote_goods'
          end
        end
        resources :wallet_templates do
          resources :advances
          resources :custom_wallets
          resources :wallet_prepayments
          resources :wallet_goods
        end
        resources :lawful_wallets
        resources :lawful_advances do
          collection do
            get :lawful
          end
        end
        resources :wallets, only: [] do
          resources :wallet_payments do
            collection do
              post :batch
            end
          end
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
        controller :home do
          get :index
        end
        resources :orders, only: [] do
          collection do
            delete :batch_destroy
          end
          member do
            match :edit_organ, via: [:get, :post]
            post :batch_receive
          end
          resources :order_payments
        end
        resources :items, only: [] do
          member do
            match :edit_price, via: [:get, :post]
            post :edit_number
            patch :update_price
          end
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
        root 'home#index'
        resources :carts do
          member do
            patch :bind
          end
        end
      end

      namespace :me, defaults: { namespace: 'me' } do
        concerns :orderable
        controller :home do
          get :qrcode
          match :qrcode_file, via: [:get, :post]
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
    url_for(controller: 'trade/my/card_templates', action: 'show', id: purchase.card_template_id)
  end
  resolve 'Trade::Advance' do |advance|
    if advance.wallet_template_id
      url_for(controller: 'trade/my/wallet_templates', action: 'show', id: advance.wallet_template_id)
    else
      url_for(controller: 'trade/my/lawful_wallets', action: 'show')
    end
  end
end
