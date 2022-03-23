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

    def get_agent_trade_item(good_type:, good_id:, number: 1, **options)
      args = {
        'good_type' => good_type,
        'good_id' => good_id.to_i,
        'produce_on' => nil,
        'scene_id' => nil,
        'member_id' => nil
      }
      args.merge! 'produce_on' => options[:produce_on].to_date if options[:produce_on].present?
      args.merge! 'scene_id' => options[:scene_id].to_i if options[:scene_id].present?
      args.merge! 'member_id' => options[:member_id].to_i if options[:member_id].present?

      trade_item = agent_trade_items.find(&->(i){ i.attributes.slice('good_type', 'good_id', 'produce_on', 'scene_id', 'member_id') == args }) || agent_trade_items.build(args)

      if trade_item.persisted? && trade_item.status_checked?
        trade_item.number += (number.present? ? number.to_i : 1)
      elsif trade_item.persisted? && trade_item.status_init?
        trade_item.status = 'checked'
        trade_item.number = 1
      else
        trade_item.status = 'checked'
      end

      trade_item
    end

    def get_trade_item(good_type:, good_id:, **options)
      args = {
        'good_type' => good_type,
        'good_id' => good_id,
        'produce_on' => nil,
        'scene_id' => nil
      }
      args.merge! 'produce_on' => options[:produce_on].to_date if options[:produce_on].present?
      args.merge! 'scene_id' => options[:scene_id].to_i if options[:scene_id].present?

      trade_items.find(&->(i){ i.attributes.slice('good_type', 'good_id', 'produce_on', 'scene_id') == args })
    end

    class_methods do

      def credit_ids
        PaymentStrategy.where.not(period: 0).pluck(:id)
      end

    end

  end
end
