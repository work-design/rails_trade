class SummaryService
  attr_reader :checked_items, :buyer, :extra,
              :promote_charges, :promote_price,
              :serve_charges, :serve_price, :total_serve_price
  attr_accessor :bulk_price, :final_price, :discount_price, :retail_price, :reduced_price,
                :total_quantity

  def initialize(_checked_items, buyer_id: nil, extra: {})
    @checked_items = _checked_items
    @buyer = Buyer.find(buyer_id) if buyer_id
    @extra = extra
    compute_total
    compute_promote
    compute_serve
  end

  def compute_price
    @bulk_price = checked_items.sum { |cart_item| cart_item.bulk_price }
  end

  def compute_total
    compute_price
    self.reduced_price = checked_items.sum { |cart_item| cart_item.reduced_price }
    self.discount_price = checked_items.sum { |cart_item| cart_item.discount_price }
    self.retail_price = checked_items.sum { |cart_item| cart_item.retail_price }
    self.final_price = checked_items.sum { |cart_item| cart_item.final_price }
    self.total_quantity = checked_items.sum { |cart_item| cart_item.total_quantity }
  end

  def compute_promote
    @promote_charges = []
    Promote.sequence.each do |quence|
      AmountPromote.total.overall.where(sequence: quence).each do |promote|
        charge = promote.compute_price(bulk_price)
        @promote_charges << charge
      end

      if buyer
        buyer.promotes.total.where(sequence: quence).each do |promote|
          charge = promote.compute_price(bulk_price)
          @promote_charges << charge
        end
      end

      compute_price
    end

    @promote_price = @promote_charges.map(&:subtotal).sum
  end

  def compute_serve
    @serve_charges = []

    QuantityServe.total.overall.each do |serve|
      charge = serve.compute_price(total_quantity, extra)
      @serve_charges << charge
    end

    @serve_price = checked_items.sum { |cart_item| cart_item.serve_price }
    @total_serve_price = serve_charges.sum { |i| i.subtotal }
  end

  def total_price
    @total_price ||= @bulk_price + @reduced_price + @promote_price + @total_serve_price
  end

end
