class PromoteService
  attr_reader :checked_items, :subtotal, :discount_subtotal, :total_subtotal, :charges, :prices

  def initialize(checked_ids)
    @checked_items = CartItem.where(id: checked_ids)
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
  end

end
