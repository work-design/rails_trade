# cart_item
# good
class ServeFee
  attr_reader :good, :number, :buyer, :extra,
              :charges, :total_charges

  def initialize(good_type, good_id, number = 1, buyer_id = nil, extra = {})
    @good = good_type.constantize.unscoped.find good_id
    @number = number
    @buyer = Buyer.find(buyer_id) if buyer_id
    @extra = extra
    verbose_fee
  end

  def verbose_fee
    @charges = []
    @total_charges = []

    Serve.single.overall.default.each do |serve|
      charge = get_charge(serve)
      @charges << charge if charge
    end

    Serve.total.overall.each do |serve|
      charge = get_charge(serve)
      @total_charges << charge if charge
    end

    @charges
  end

  def subtotal
    @subtotal ||= self.charges.map(&:subtotal).sum
  end

  def get_charge(serve)
    if serve.is_a? QuantityServe
      charge = serve.compute_price(good.quantity * number, extra)
    elsif serve.is_a? NumberServe
      charge = serve.compute_price(number, extra)
    else
      charge = serve.compute_price(number, extra)
    end
    charge
  end

end
