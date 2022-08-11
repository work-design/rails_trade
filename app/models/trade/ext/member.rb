module Trade
  module Ext::Member
    extend ActiveSupport::Concern

    included do
      attribute :promote_goods_count, :integer, default: 0

      #has_many :payment_references, class_name: 'Trade::PaymentReference', dependent: :destroy_async
      #has_many :payment_methods, through: :payment_references
      has_many :wallets, class_name: 'Trade::Wallet'
      has_many :cards, class_name: 'Trade::Card'
      has_many :carts, ->{ where(organ_id: nil) }, class_name: 'Trade::Cart'
      has_many :items, class_name: 'Trade::Item'
      has_many :cart_items, ->{ carting }, class_name: 'Trade::Item'
      has_many :agent_items, class_name: 'Trade::Item', foreign_key: :agent_id
      has_many :orders, class_name: 'Trade::Order'
      has_many :from_orders, class_name: 'Trade::Order', foreign_key: :from_member_id
      has_many :promote_goods, class_name: 'Trade::PromoteGood'

      scope :credited, -> { where(payment_strategy_id: self.credit_ids) }
    end

    def promotes_count
      r = PromoteGood.effective.where(member_id: nil).count
      r + promote_goods_count
    end

    def last_overdue_date
      orders.order(overdue_date: :asc).first&.overdue_date
    end

    def get_agent_item(good_type:, good_id:, number: 1, **options)
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

      item = agent_items.carting.find(&->(i){ i.attributes.slice('good_type', 'good_id', 'produce_on', 'scene_id', 'member_id') == args }) || agent_items.build(args)

      if item.persisted? && item.status_checked?
        item.number += (number.present? ? number.to_i : 1)
      elsif item.persisted? && item.status_init?
        item.status = 'checked'
        item.number = 1
      else
        item.status = 'checked'
      end

      item
    end

    def get_item(good_type:, good_id:, aim: 'use', **options)
      args = { good_type: good_type, good_id: good_id, aim: aim }
      args.merge! 'produce_on' => options[:produce_on].to_date if options[:produce_on].present?
      args.merge! 'scene_id' => options[:scene_id].to_i if options[:scene_id].present?

      items.find(&->(i){ i.attributes.slice('good_type', 'good_id', 'aim', 'produce_on', 'scene_id').reject(&->(_, v){ v.blank? }) == args.stringify_keys })
    end

    class_methods do

      def credit_ids
        PaymentStrategy.where.not(period: 0).pluck(:id)
      end

    end

  end
end
