class AdditionService
  attr_reader :checked_items, :buyer,
              :total_quantity,
              :bulk_price, :discount_price, :retail_price,
              :promote_price, :serve_price,
              :promote_charges, :serve_charges

  def initialize(checked_ids, buyer_id = nil)
    @checked_items = CartItem.where(id: checked_ids)
    @buyer = Buyer.find(buyer_id) if buyer_id
    compute_total
    compute_promote
    compute_serve
  end

  def compute_price
    @bulk_price = checked_items.sum { |cart_item| cart_item.bulk_price }
  end

  def compute_total
    compute_price
    @discount_price = checked_items.sum { |cart_item| cart_item.discount_price }
    @retail_price = checked_items.sum { |cart_item| cart_item.retail_price }
    @total_quantity = checked_items.sum { |cart_item| cart_item.total_quantity }
  end

  def compute_promote
    @promote_charges = []
    Promote.sequence.each do |quence|
      AmountPromote.total.overall.where(sequence: quence).each do |promote|
        charge = promote.compute_price(bulk_price)
        @promote_charges << charge if charge
      end

      if buyer
        buyer.promotes.total.where(sequence: quence).each do |promote|
          charge = promote.compute_price(bulk_price)
          @promote_charges << charge if charge
        end
      end

      compute_price
    end

    @promote_price = @promote_charges.map(&:subtotal).sum
  end

  def compute_serve
    @serve_charges = []

    QuantityServe.overall.total.each do |serve|
      serve = serve.compute_price(total_quantity)
      @serve_charges << serve if serve.persisted?
    end
    @serve_price = @serve_charges.map(&:subtotal).sum
  end

  def total_price
    @total_price ||= @bulk_price + @promote_price + @serve_price
  end

end
