class PromoteFee
  thread_mattr_accessor :current_currency, instance_accessor: true
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

    QuantityPromote.overall.single.each do |promote|
      charge = promote.compute_price(good.quantity * number, extra)
      if charge
        charge.subtotal = charge.final_price(good.quantity * number)
        @charges << charge
      end
    end

    NumberPromote.overall.single.each do |promote|
      charge = promote.compute_price(number)
      if charge

        charge.subtotal = charge.final_price(price)
        @charges << charge
      end
    end

    AmountPromote.overall.single.each do |promote|
      charge = promote.compute_price(price)
      @charges << charge if charge
    end

    if buyer
      buyer.promotes.each do |promote|
        charge = promote.compute_price(total_subtotal)
        if charge
          charge.subtotal = charge.final_price(total_subtotal)
          @charges << charge
        end
      end
    end

    @charges
  end

  def subtotal
    @subtotal ||= self.charges.map(&:subtotal).sum(good.price * number)
  end

end
