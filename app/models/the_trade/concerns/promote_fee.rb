class PromoteFee
  attr_reader :good, :number, :charges, :prices, :discount

  def initialize(good_type, good_id, number = 1)
    @good = good_type.constantize.unscoped.find good_id
    @number = number
    verbose_fee
  end

  def compute_fee
    @prices.values.sum(good.price)
  end

  def verbose_fee
    @charges = []
    @prices = {}
    @discount = {}
    SinglePromote.verified.each do |promote|
      charge = promote.compute_price(good.quantity, good.unit)
      if charge
        @charges << charge
        @prices.merge! promote.name => charge.final_price(good.quantity)
        @discount.merge! promote.name => charge.discount_price(good.quantity, number) if number > 1
      end
    end
    QuantityPromote.verified.each do |promote|
      charge = promote.compute_price(number, nil)
      if charge
        @charges << charge
        @prices.merge! promote.name => charge.final_price(number)
      end
    end
    @charges
  end

  def single_subtotal
    self.compute_fee.to_d
  end

end
