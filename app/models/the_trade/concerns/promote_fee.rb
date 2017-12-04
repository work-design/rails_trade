class PromoteFee
  attr_reader :good, :number, :buyer,
              :extra, :charges

  def initialize(good_type, good_id, number = 1, buyer_id = nil, extra = {})
    @good = good_type.constantize.unscoped.find good_id
    @number = number
    @buyer = Buyer.find(buyer_id) if buyer_id
    @extra = extra
    verbose_fee
  end

  def verbose_fee
    @charges = []

    Promote.single.overall.each do |promote|
      charge = get_charge_by_promote(promote)
      @charges << charge if charge
    end

    if buyer
      buyer.promotes.single.each do |promote|
        charge = get_charge_by_promote(promote)
        @charges << charge if charge
      end
    end

    @charges
  end

  def pure_price
    good.price * number
  end

  def subtotal
    @subtotal ||= self.charges.map(&:subtotal).sum
  end

  def get_charge_by_promote(promote)
    if serve.type == 'AmountPromote'
      charge = promote.compute_price(pure_price)
    else
      charge = promote.compute_price(pure_price)
    end
    charge
  end

  def get_charge_by_promote_id(promote_id)
    promote = Promote.find promote_id
    get_charge_by_promote(promote)
  end

end
