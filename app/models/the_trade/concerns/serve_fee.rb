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

    good.good_serves

    QuantityServe.where.not(id: []).single.overall.each do |serve|
      charge = serve.compute_price(good.quantity * number, extra)
      good_serve = good.good_serves.find { |i| i.serve_id == serve.id }
      charge.subtotal = good_serve.price if good_serve
      @charges << charge
    end

    NumberServe.single.overall.each do |serve|
      charge = serve.compute_price(number, extra)
      good_serve = good.good_serves.find { |i| i.serve_id == serve.id }
      charge.subtotal = good_serve.price if good_serve
      @charges << charge
    end

   

    @charges
  end

  def subtotal
    @subtotal ||= self.charges.map(&:subtotal).sum
  end

end
