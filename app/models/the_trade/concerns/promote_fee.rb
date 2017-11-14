class PromoteFee
  attr_reader :good

  def initialize(good_type, good_id)
    @good = good_type.constantize.unscoped.find good_id
  end

  def compute_fee
    verbose_fee.values.sum(good.price)
  end

  def verbose_fee
    _result = {}
    SinglePromote.verified.each do |promote|
      _result.merge! promote.name => promote.compute_price(good.quantity, good.unit)
    end
    _result
  end

  def single_subtotal
    self.compute_fee.to_d
  end

end
