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

    QuantityServe.single.overall.each do |serve|
      charge = serve.compute_price(good.quantity * number, extra)
      @charges << charge if charge
    end

    NumberServe.single.overall.each do |serve|
      charge = serve.compute_price(number)
      @charges << charge if charge
    end

    @charges
  end

  def subtotal
    @subtotal ||= self.charges.map(&:subtotal).sum
  end

end
