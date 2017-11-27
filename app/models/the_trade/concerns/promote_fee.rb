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

    AmountPromote.overall.single.each do |promote|
      charge = promote.compute_price(price)
      @charges << charge if charge
    end

    if buyer
      buyer.promotes.each do |promote|
        charge = promote.compute_price(retail_price)
        if charge
          charge.subtotal = charge.final_price(retail_price)
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
