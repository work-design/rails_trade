class PromoteFee
  attr_reader :good

  def initialize(good_type, good_id)
    @good = good_type.constantize.unscoped.find good_id
  end

  def compute_fee
    _amount = good.price

    if good.unit
      promotes = Promote.where(unit: [good.unit, nil])
      promotes.each do |promote|
        _amount += promote.compute_price(good.quantity, good.unit)
      end
    end

    _amount
  end

  def single_subtotal
    self.compute_fee.to_d
  end

end
