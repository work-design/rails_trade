module RailsTrade::Sell
  extend ActiveSupport::Concern

  included do
    include RailsTrade::Good
    attribute :buyer_type, :string
    attribute :buyer_id, :integer

    belongs_to :buyer, polymorphic: true, optional: true

    has_one :order_item, as: :good, dependent: :nullify
    has_one :order, ->(o){ where(buyer_type: o.buyer.class.name, buyer_id: o.buyer.id) }, through: :order_item
  end

  def update_order
    order_item.update amount: self.price
  end

  def get_order
    return @get_order if defined?(@get_order)
    @get_order = self.order || generate_order!(self.buyer, { number: 1 })
  end

end
