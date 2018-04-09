module TheStripe
  extend ActiveSupport::Concern

  included do
  end

  def stripe_charge(params = {})
    if params[:token]
      TheStripe.stripe_customer(buyer: self.buyer, token: params[:token])
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

  # execute payment
  # required:
  # token
  def self.stripe_customer(buyer:, **params)
    payment_method = buyer.payment_methods.build(type: 'StripeMethod')
    payment_method.token = params[:token]
    payment_method.detective_save
    payment_method
  end

end
