module Trade
  module Ext::Organ
    extend ActiveSupport::Concern

    included do
      has_many :member_carts, class_name: 'Trade::Cart', foreign_key: :member_organ_id
      has_many :member_trade_items, class_name: 'Trade::TradeItem', through: :member_carts, source: :trade_items
      has_many :member_orders, class_name: 'Trade::Order', foreign_key: :member_organ_id
      has_many :member_ordered_trade_items, class_name: 'Trade::TradeItem', through: :member_orders, source: :trade_items
    end

  end
end

