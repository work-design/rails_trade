class PromoteService
  attr_reader :buyer, :checked_items, :subtotal, :discount_subtotal, :total_subtotal, :total, :charges, :prices

  def initialize(checked_ids, buyer_id = nil)
    @checked_items = CartItem.where(id: checked_ids)
    @buyer = Buyer.find(buyer_id) if buyer_id
    compute_total
    compute_promote
  end

  def compute_total
    @subtotal = checked_items.sum { |cart_item| cart_item.subtotal }
    @discount_subtotal = checked_items.sum { |cart_item| cart_item.discount_subtotal }
    @total_subtotal = checked_items.sum { |cart_item| cart_item.total_subtotal }
  end

  def compute_promote
    @charges = []
    @prices = {}
    WidePromote.verified.each do |promote|
      charge = promote.compute_price(subtotal, nil)
      if charge
        @charges << charge
        @prices.merge! promote.name => charge.final_price(subtotal)
      end
    end

    if buyer
      buyer.promotes.each do |promote|
        charge = promote.compute_price(subtotal, nil)
        if charge
          @charges << charge
          @prices.merge! promote.name => charge.final_price(subtotal)
        end
      end
    end

    discount = @prices.values.sum
    @total = @subtotal + discount
  end

end
