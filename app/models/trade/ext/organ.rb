module Trade
  module Ext::Organ
    extend ActiveSupport::Concern

    included do
      has_many :member_carts, class_name: 'Trade::Cart', foreign_key: :member_organ_id
      has_many :organ_carts, ->{ where(member_id: nil, user_id: nil) }, class_name: 'Trade::Cart', foreign_key: :member_organ_id
      has_many :organ_items, class_name: 'Trade::Item', foreign_key: :member_organ_id
      has_many :member_orders, class_name: 'Trade::Order', foreign_key: :member_organ_id
      has_many :member_ordered_items, class_name: 'Trade::Item', through: :member_orders, source: :items
      has_many :cards, -> { includes(:card_template) }, class_name: 'Trade::Card', foreign_key: :member_organ_id
      has_many :wallets, -> { includes(:wallet_template) }, class_name: 'Trade::Wallet', foreign_key: :member_organ_id
    end

    def get_item(good_type:, good_id:, aim: 'use', **options)
      args = { good_type: good_type, good_id: good_id, aim: aim }
      args.merge! 'produce_on' => options[:produce_on].to_date if options[:produce_on].present?
      args.merge! 'scene_id' => options[:scene_id].to_i if options[:scene_id].present?

      member_items.carting.find(&->(i){ i.attributes.slice('good_type', 'good_id', 'aim', 'produce_on', 'scene_id').reject(&->(_, v){ v.blank? }) == args.stringify_keys })
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

