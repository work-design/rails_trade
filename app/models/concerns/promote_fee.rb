# cart_item
# good
class PromoteFee
  attr_reader :charges

  def initialize(good_type, good_id, number: 1, buyer_type: 'User', buyer_id: nil, extra: {}, promote_id: nil)
    @good = good_type.constantize.unscoped.find good_id
    @number = number
    @buyer = buyer_type.constantize.find(buyer_id) if buyer_id
    @extra = extra
    @promote_id = promote_id
    verbose_fee
  end

  def verbose_fee
    @charges = []

    Promote.single.overall.each do |promote|
      @charges << get_charge(promote)
    end



    if @buyer
      promote = @buyer.promotes.find_by(id: @promote_id)
      if promote
        @charges << get_charge(promote)
      end
    end


    @good.promotes.each do |promote|
      @charges << get_charge(promote)
    end

    @charges.compact
  end

  def pure_price
    @good.price * @number
  end

  def retail_price
    @good.retail_price * @number
  end

  def subtotal
    @subtotal ||= self.charges.map(&:subtotal).sum
  end

  def get_charge(promote)
    if promote.is_a?(AmountPromote)
      charge = promote.compute_price(retail_price, @extra)
    elsif promote.is_a?(NumberPromote)
      charge = promote.compute_price(@number, @extra)
    else
      charge = 0
    end
    charge
  end

end
