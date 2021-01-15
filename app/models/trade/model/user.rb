module Trade
  module Model::User
    extend ActiveSupport::Concern

    included do
      has_many :carts, dependent: :destroy
      has_many :orders, dependent: :destroy
      has_many :trade_items, dependent: :destroy
      has_many :cards
      has_many :cashes
      has_many :cash_givens
    end

    def cash
      super || create_cash
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
