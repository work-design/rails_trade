class PromoteFee
  thread_mattr_accessor :current_currency, instance_accessor: true
  attr_reader :good, :buyer, :number, :extra, :charges, :prices, :discount

  def initialize(good_type, good_id, number = 1, buyer_id = nil, extra = {})
    @good = good_type.constantize.unscoped.find good_id
    @number = number
    @buyer = Buyer.find(buyer_id) if buyer_id
    @extra = extra
    verbose_fee
  end

  def compute_fee
    @charges.map(&:subtotal).sum(good.price)
  end

  def verbose_fee
    @charges = []

    QuantityPromote.overall.single.each do |promote|
      charge = promote.compute_price(good.quantity, extra)
      if charge
        charge.subtotal = charge.final_price(good.quantity)
        charge.discount = charge.discount_price(good.quantity, number) if number > 1 && promote.discount
        @charges << charge
      end
    end

    NumberPromote.overall.single.each do |promote|
      charge = promote.compute_price(number)
      if charge
        charge.subtotal = charge.final_price(number)
        @charges << charge
      end
    end

    AmountPromote.overall.single.each do |promote|
      charge = promote.compute_price(price)
      if charge
        charge.subtotal = charge.final_price(number)
        @charges << charge
      end
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

  def single_subtotal
    self.compute_fee.to_d
  end

  def discount_subtotal
    self.charges.map(&:discount).sum
  end

  def total_subtotal
    self.single_subtotal * self.number
  end

end
