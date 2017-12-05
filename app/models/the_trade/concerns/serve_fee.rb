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
      charge = get_charge_price(serve)
      @charges << charge if charge
    end

    @charges
  end

  def subtotal
    @subtotal ||= self.charges.map(&:subtotal).sum
  end

  def get_charge_price(serve)
    good_serve = good.good_serves.find { |i| i.serve_id == serve.id }

    if good_serve
      charge = get_charge(serve)
      charge.subtotal = good_serve.price
    elsif serve.default
      charge = get_charge(serve)
    else
      return
    end

    charge
  end

  def get_charge(serve)
    if serve.type == 'QuantityServe'
      charge = serve.compute_price(good.quantity * number, extra)
    elsif serve.type == 'NumberServe'
      charge = serve.compute_price(number, extra)
    else
      charge = serve.compute_price(number, extra)
    end
    charge
  end

end
