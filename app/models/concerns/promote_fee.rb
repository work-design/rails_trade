# cart_item
# good
class PromoteFee
  attr_reader :good, :number, :buyer,
              :extra, :charges

  def initialize(good_type, good_id, number: 1, buyer_type: 'User', buyer_id: nil, extra: {})
    @good = good_type.constantize.unscoped.find good_id
    @number = number
    @buyer = buyer_type.constantize.find(buyer_id) if buyer_id
    @extra = extra
    verbose_fee
  end

  def verbose_fee
    @charges = []

    Promote.single.overall.each do |promote|
      charge = get_charge(promote)
      @charges << charge
    end

    if buyer
      buyer.promotes.single.each do |promote|
        charge = get_charge(promote)
        @charges << charge
      end
    end

    good.promotes.each do |promote|
      charge = get_charge(promote)
      @charges << charge
    end

    @charges
  end

  def pure_price
    good.price * number
  end

  def retail_price
    good.retail_price * number
  end

  def subtotal
    @subtotal ||= self.charges.map(&:subtotal).sum
  end

  def get_charge(promote)
    if promote.is_a?(AmountPromote)
      charge = promote.compute_price(retail_price)
    else
      charge = promote.compute_price(number)
    end
    charge
  end

end
