class ServeFee
  attr_reader :good, :number, :buyer, :extra,
              :charges

  def initialize(good_type, good_id, number = 1, buyer_id = nil, extra = {})
    @good = good_type.constantize.unscoped.find good_id
    @number = number
    @buyer = Buyer.find(buyer_id) if buyer_id
    @extra = extra
    verbose_fee
  end

  def verbose_fee
    @charges = []

    Serve.single.overall.each do |serve|
      good_serve = good.good_serves.find { |i| i.serve_id == serve.id }

      if !good_serve && !serve.default
        next
      end

      charge = get_charge_by_serve(serve)
      charge.subtotal = good_serve.price if good_serve

      @charges << charge
    end

    @charges
  end

  def subtotal
    @subtotal ||= self.charges.map(&:subtotal).sum
  end

  def get_charge_by_serve(serve)
    if serve.type == 'QuantityServe'
      charge = serve.compute_price(good.quantity * number, extra)
    elsif serve.type == 'NumberServe'
      charge = serve.compute_price(number, extra)
    else
      charge = serve.compute_price(number, extra)
    end
    charge
  end

  def get_charge_by_serve_id(serve_id)
    serve = Serve.find serve_id
    get_charge_by_serve(serve)
  end

end
