module Trade
  module Model::Sell
    extend ActiveSupport::Concern

    included do
      include RailsTrade::Good

      belongs_to :buyer, optional: true

      has_one :trade_item, as: :good, dependent: :nullify
      has_one :order, ->(o){ where(buyer_type: o.buyer.class.name, buyer_id: o.buyer.id) }, through: :order_item
    end

    def update_order
      order_item.update amount: self.price
    end

    def get_order
      return @get_order if defined?(@get_order)
      @get_order = self.order || generate_order!(buyer: self.buyer, number: 1)
    end

  end
end
