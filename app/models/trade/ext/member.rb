module Trade
  module Ext::Member
    extend ActiveSupport::Concern

    included do
      #has_many :payment_references, class_name: 'Trade::PaymentReference', dependent: :destroy_async
      #has_many :payment_methods, through: :payment_references
      has_many :carts, class_name: 'Trade::Cart'
      has_many :trade_items, class_name: 'Trade::TradeItem'
      has_many :cart_trade_items, ->{ carting }, class_name: 'Trade::TradeItem'
      has_many :agent_trade_items, class_name: 'Trade::TradeItem', foreign_key: :agent_id
      has_many :orders, class_name: 'Trade::Order'

      scope :credited, -> { where(payment_strategy_id: self.credit_ids) }
    end

    def last_overdue_date
      orders.order(overdue_date: :asc).first&.overdue_date
    end

    class_methods do

      def credit_ids
        PaymentStrategy.where.not(period: 0).pluck(:id)
      end

    end

  end
end
