module Trade
  module Model::Purchase
    extend ActiveSupport::Concern

    included do
      attribute :price, :decimal
      attribute :note, :string
      attribute :years, :integer, default: 0
      attribute :months, :integer, default: 0
      attribute :days, :integer, default: 0

      belongs_to :card_template

      has_one_attached :logo
      delegate :cover, to: :card_template
    end

    def name
      "#{card_template.name}-#{price}"
    end

    def order_paid(trade_item)
      if trade_item.respond_to?(:maintain) && trade_item.maintain
        card = card_template.cards.find_or_initialize_by(client_type: trade_item.maintain.client_type, client_id: trade_item.maintain.client_id)
        card.agency_id = trade_item.maintain.agency_id
      else
        card = card_template.cards.find_or_initialize_by(cart_id: trade_item.cart_id)
      end
      ca = card.card_advances.build
      ca.trade_item = trade_item
      ca.amount = amount

      card.class.transaction do
        card.save!
        ca.save!
        trade_item.maintain.transfer! if trade_item.respond_to?(:maintain) && trade_item.maintain
      end

      card
    end

  end
end
