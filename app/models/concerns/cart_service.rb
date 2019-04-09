class CartService
  attr_reader :promote_charges,
              :promote_price,
              :serve_charges,
              :serve_price,
              :total_serve_price
  attr_accessor :bulk_price,
                :final_price,
                :discount_price,
                :retail_price,
                :total_quantity

  def initialize(buyer_type: 'User', buyer_id: nil, session_id: nil, cart_item_id: nil, myself: nil, extra: {})
    if cart_item_id
      @checked_items = CartItem.where(id: cart_item_id)
      @buyer = @checked_items.first.buyer
    elsif buyer_id
      @buyer = buyer_type.constantize.find(buyer_id)
      @checked_items = @buyer.cart_items.default_where(myself: myself).init.checked
    elsif session_id
      @checked_items = CartItem.default_where(session_id: session_id, myself: myself).init.checked
    else
      @checked_items = CartItem.none
    end
    @extra = extra
    compute_promote
    compute_serve
  end

  def compute_price
    self.bulk_price = @checked_items.sum(&:bulk_price)
  end

  def compute_promote
    @promote_charges = []
    Promote.sequence.each do |que|
      AmountPromote.total.overall_goods.where(sequence: que).each do |promote|
        @promote_charges << promote.compute_price(bulk_price)
      end

      if @buyer
        @buyer.promotes.total.where(sequence: que).each do |promote|
          @promote_charges << promote.compute_price(bulk_price)
        end
      end

      compute_price
    end

    @promote_price = @promote_charges.map(&:subtotal).sum
  end

  def compute_serve
    @serve_charges = []

    QuantityServe.total.overall.each do |serve|
      charge = serve.compute_price(total_quantity, @extra)
      @serve_charges << charge
    end

    @serve_price = @checked_items.sum(&:serve_price)
    @total_serve_price = serve_charges.sum(&:subtotal)
  end

  def total_price
    @total_price ||= bulk_price + promote_price + @total_serve_price
  end

end
