module Trade
  module Ext::User
    extend ActiveSupport::Concern

    included do
      attribute :promote_goods_count, :integer, default: 0

      has_many :carts, -> { order(id: :asc) }, class_name: 'Trade::Cart'
      has_many :wallets, class_name: 'Trade::Wallet'
      has_many :orders, class_name: 'Trade::Order'
      has_many :trade_items, class_name: 'Trade::TradeItem'
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

    def init_wallet(platform = nil)
      if platform == 'ios'
        self.ios_wallet || self.create_ios_wallet
        ios_wallet.set_active
      else
        self.normal_wallet || self.create_normal_wallet
        normal_wallet.set_active
      end
    end

  end
end
