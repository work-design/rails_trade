Rails.application.routes.draw do
  scope RailsCom.default_routes_scope do
    concern :orderable do
      resources :orders do
        collection do
          match :blank, via: [:get, :post]
          post :add
          post :trial
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
          get :payment_type
          get :logs
          get 'cancel' => :edit_cancel
          put 'cancel' => :update_cancel
          put :refund
          patch :cancel
          get :success
        end
        resources :packages
      end
      resources :trade_items do
        collection do
          post :trial
        end
        member do
          patch :toggle
          get :promote
        end
      end
      resources :carts do
        collection do
          get :list
          get :addresses
          get :promote
        end
      end
      resources :promote_goods, only: [:index, :show]
      resources :card_templates do
        member do
          get :code
        end
      end
      resources :wallet_templates
      resources :wallets do
        resources :wallet_logs, only: [:index, :show]
      end
    end

    concern :order_admin do
      resources :orders do
        collection do
          get :payments
          get :refresh
        end
        member do
          get :payment_types
          patch :refund
          post :package
          get :print_data
          get :payment_orders
          get :payment_new
          patch :payment_create
          delete :payment_destroy
        end
      end
      resources :payments do
        collection do
          get :dashboard
          get :order_new
          post :order_create
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
    end

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
      resources :orders, only: [] do
        member do
          get :qrcode
        end
      end

      namespace :panel, defaults: { namespace: 'panel' } do
        root 'home#index'
        concerns :order_admin
        resources :exchange_rates
        resources :units
        resources :trade_items do
          member do
            get :carts
          end
        end
      end

      namespace :admin, defaults: { namespace: 'admin' } do
        root 'home#index'
        concerns :order_admin
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
        resources :trade_items
        resources :cart_promotes
        resources :item_promotes
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
          resources :promote_good_users do
            collection do
              post :user_search
              post :good_search
              get :user
            end
          end
        end
        resources :promote_charges, only: [] do
          collection do
            get :options
          end
        end
        resources :promote_goods
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
        resources :wallet_templates do
          resources :advances
          resources :wallet_prepayments
          resources :wallets do
            resources :wallet_payments
            resources :wallet_advances
            resources :wallet_logs
            resources :payouts do
              member do
                put :do_pay
              end
            end
          end
        end
      end

      namespace :in, defaults: { namespace: 'in' } do
        resources :trade_items do
          collection do
            post :cost
          end
        end
      end

      namespace :my, defaults: { namespace: 'my' } do
        concerns :orderable
        resources :payments do
          collection do
            get :order_new
            post :order_create
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

      namespace :our, defaults: { namespace: 'our' } do
        concerns :orderable
      end
    end
  end
  resolve 'Trade::Purchase' do |purchase, options|
    [:trade, :my, purchase.card_template, options]
  end
  resolve 'Trade::Advance' do |advance, options|
    [:trade, :my, advance.wallet_template, options]
  end
end
