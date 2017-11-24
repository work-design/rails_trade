class ServeFee
  attr_reader :good, :number, :buyer, :extra, :charges

  def initialize(good_type, good_id, number = 1, buyer_id = nil, extra = {})
    @good = good_type.constantize.unscoped.find good_id
    @number = number
    @buyer = Buyer.find(buyer_id) if buyer_id
    @extra = extra
    verbose_fee
  end

  def verbose_fee
    @charges = []

    QuantityServe.overall.single.each do |serve|
      charge = serve.compute_price(good.quantity * number, extra)
      if charge
        @charges << charge
      end
    end

    NumberServe.overall.single.each do |serve|
      charge = serve.compute_price(number)
      if charge
        @charges << charge
      end
    end

    @charges
  end

  def subtotal
    @subtotal ||= self.charges.map(&:subtotal).sum(good.price * number)
  end

end
