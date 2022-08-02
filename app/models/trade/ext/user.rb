module Trade
  module Ext::User
    extend ActiveSupport::Concern

    included do
      attribute :promote_goods_count, :integer, default: 0

      has_many :carts, class_name: 'Trade::Cart'
      has_many :wallets, class_name: 'Trade::Wallet'
      has_many :cards, class_name: 'Trade::Card'
      has_many :orders, class_name: 'Trade::Order'
      has_many :from_orders, class_name: 'Trade::Order', foreign_key: :from_user_id
      has_many :trade_items, class_name: 'Trade::TradeItem'
      has_many :rents, -> { aim_rent }, class_name: 'Trade::TradeItem'
      has_many :payments, class_name: 'Trade::Payment'
      has_many :promote_goods, class_name: 'Trade::PromoteGood'

      has_many :cart_trade_items, ->{ carting }, class_name: 'Trade::TradeItem'
    end

    def give_cash(amount, note: nil, **options)
      raise ArgumentError if amount <= 0
      cash.cash_givens.create!(amount: amount, note: note, **options)
    end

    def wxpay_openid
      oauth_users.where(type: 'WechatUser').first&.uid
    end

    def promotes_count
      r = PromoteGood.effective.where(user_id: nil).count
      r + promote_goods_count
    end

    def init_wallet(platform = nil)
      if platform == 'ios'
        self.ios_wallet || self.create_ios_wallet
        ios_wallet.set_active
      else
        self.normal_wallet || self.create_normal_wallet
        normal_wallet.set_active
      end
    end

    def get_trade_item(good_type:, good_id:, aim: 'use', **options)
      args = { good_type: good_type, good_id: good_id, aim: aim, **options.slice(:fetch_oneself) }
      args.merge! 'produce_on' => options[:produce_on].to_date if options[:produce_on].present?
      args.merge! 'scene_id' => options[:scene_id].to_i if options[:scene_id].present?
      args.reject!(&->(_, v){ v.blank? })

      trade_items.find(&->(i){ i.attributes.slice('good_type', 'good_id', 'aim', 'produce_on', 'scene_id', 'fetch_oneself').reject(&->(_, v){ v.blank? }) == args.stringify_keys })
    end

  end
end
