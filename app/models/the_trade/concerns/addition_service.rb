class AdditionService
  attr_reader :checked_items, :buyer, :bulk_price, :discount_price, :retail_price, :total,
              :promote_charges, :serve_charges

  def initialize(checked_ids, buyer_id = nil)
    @checked_items = CartItem.where(id: checked_ids)
    @buyer = Buyer.find(buyer_id) if buyer_id
    compute_total
    compute_promote
    compute_serve
  end

  def compute_total
    @bulk_price = checked_items.sum { |cart_item| cart_item.bulk_price }
    @discount_price = checked_items.sum { |cart_item| cart_item.discount_price }
    @retail_price = checked_items.sum { |cart_item| cart_item.retail_price }
  end

  def compute_promote
    @promote_charges = []
    AmountPromote.overall.total.each do |promote|
      charge = promote.compute_price(bulk_price)
      if charge
        @promote_charges << charge
      end
    end

    if buyer
      buyer.promotes.each do |promote|
        charge = promote.compute_price(subtotal)
        if charge
          @promote_charges << charge
        end
      end
    end

    discount = @promote_charges.map(&:subtotal).sum
    @bulk_price + discount
  end

  def compute_serve
    @serve_charges = []

    QuantityServe.overall.total.each do |serve|
      serve = serve.compute_price(bulk_price)
      if serve
        @serve_charges << serve
      end
    end
  end

end
