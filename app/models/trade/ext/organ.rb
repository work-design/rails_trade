module Trade
  module Ext::Organ
    extend ActiveSupport::Concern

    included do
      has_many :member_carts, class_name: 'Trade::Cart', foreign_key: :member_organ_id
      has_many :member_trade_items, class_name: 'Trade::TradeItem', foreign_key: :member_organ_id
      has_many :member_orders, class_name: 'Trade::Order', foreign_key: :member_organ_id
      has_many :member_ordered_trade_items, class_name: 'Trade::TradeItem', through: :member_orders, source: :trade_items
      has_many :cards, -> { includes(:card_template) }, foreign_key: :member_organ_id
      has_many :wallets, -> { includes(:wallet_template) }, foreign_key: :member_organ_id
    end

    def get_trade_item(good_type:, good_id:, aim: 'use', **options)
      args = { good_type: good_type, good_id: good_id, aim: aim }
      args.merge! 'produce_on' => options[:produce_on].to_date if options[:produce_on].present?
      args.merge! 'scene_id' => options[:scene_id].to_i if options[:scene_id].present?

      member_trade_items.carting.find(&->(i){ i.attributes.slice('good_type', 'good_id', 'aim', 'produce_on', 'scene_id').reject(&->(_, v){ v.blank? }) == args.stringify_keys })
    end

    def owned?(template)
      if template.is_a?(WalletTemplate)
        wallets.find(&->(i){ i.wallet_template_id == template.id })
      elsif template.is_a?(CardTemplate)
        cards.find_by(card_template_id: template.id, temporary: false)
      else
        nil
      end
    end

  end
end

