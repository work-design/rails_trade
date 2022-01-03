module Trade
  module Ext::Organ
    extend ActiveSupport::Concern

    included do
      has_many :member_carts, class_name: 'Trade::Cart', foreign_key: :member_organ_id
      has_many :member_trade_items, class_name: 'Trade::TradeItem', through: :member_carts, source: :trade_items
    end

  end
end

