module TheStripe
  extend ActiveSupport::Concern

  included do
  end

  # execute payment
  # required:
  # token
  def self.stripe_customer(params)
    payment_method = PaymentMethod.new(buyer_id: params[:buyer_id], type: 'StripeMethod')

    begin
      customer = Stripe::Customer.create(description: "buyer: #{params[:buyer_id]}", source: params[:token])
      payment_method.account_num = customer.id
      payment_method.extra = payment_method.customer_info(customer)
    rescue Stripe::StripeError => ex
      payment_method.errors.add :base, ex.message
    end
    payment_method.save if payment_method.valid?
    payment_method
  end

  def stripe_charge(params = {})
    if params[:token]
      TheStripe.stripe_customer(token: params[:token], buyer_id: self.buyer_id)
    end

    if params[:payment_method_id]
      stripe_payment_method = buyer.payment_methods.where(type: 'StripeMethod', id: params[:payment_method_id]).first
    else
      stripe_payment_method = buyer.payment_methods.where(type: 'StripeMethod').first
    end

    unless stripe_payment_method
      self.errors.add :base, 'Please add credit card at first.'
      return self
    end
    return self if self.amount <= 0

    begin
      charge = Stripe::Charge.create(amount: self.amount_money.cents, currency: self.currency, customer: stripe_payment_method.account_num)
      self.update payment_type: 'stripe', payment_id: charge.id
      self.stripe_record(charge)
    rescue Stripe::StripeError => ex
      self.errors.add :base, ex.message
    end
    self
  end

  def stripe_result
    if self.payment_id.present?
      charge = Stripe::Charge.retrieve(self.payment_id)
      self.stripe_record(charge)
    end
  end

  def stripe_record(charge)
    if charge.paid && !charge.refunded
      existing = StripePayment.find_by(payment_uuid: charge.id)
      return existing if existing

      stripe = StripePayment.new
      stripe.payment_uuid = charge.id
      stripe.total_amount = Money.new(charge.amount, self.currency).to_d
      stripe.currency = charge.currency.upcase

      payment_order = stripe.payment_orders.build(order_id: self.id, check_amount: stripe.total_amount)

      Payment.transaction do
        payment_order.confirm!
        stripe.save!
      end
      stripe
    else
      errors.add :uuid, 'error'
    end
  end

end
