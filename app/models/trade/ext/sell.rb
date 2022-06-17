module Trade
  module Ext::Sell
    extend ActiveSupport::Concern

    included do
      include Ext::Good

      belongs_to :user, class_name: 'Auth::User', optional: true

      has_one :trade_item, as: :good, class_name: 'Trade::TradeItem', dependent: :nullify
      has_one :order, through: :trade_item
    end

    def update_order
      trade_item.update amount: self.price
    end

    def get_order
      return @get_order if defined?(@get_order)
      @get_order = self.order || generate_order!(buyer: self.buyer, number: 1)
    end

  end
end
