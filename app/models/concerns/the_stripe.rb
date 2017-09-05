module TheStripe
  extend ActiveSupport::Concern

  included do

  end

  # execute payment
  # required:
  # token
  def customer_execute(params)
    customer = Stripe::Customer.create(description: "#{buyer_type}:#{buyer_id}", source: params[:token])

    payment_method = buyer.payment_methods.build(type: 'StripeMethod')
    payment_method.account_num = customer.id
    payment_method.extra = payment_method.customer_info(customer)
    payment_method.save
  end

  def stripe_payment_method
    buyer.payment_methods.where(type: 'StripeMethod').first
  end

  def stripe_execute
    charge = Stripe::Charge.create(amount: (self.amount * 100).to_i, currency: self.currency, customer: stripe_payment_method.account_num)
    self.stripe_record(charge)
    self.update payment_id: charge.id
  end

  def stripe_result
    if self.payment_type == 'stripe' && self.payment_id.present?
      charge = Stripe::Charge.retrieve(self.payment_id)
      self.stripe_record(charge)
    end
  end

  def stripe_record(charge)
    if charge.paid
      stripe = StripePayment.new
      stripe.payment_uuid = charge.id
      stripe.total_amount = charge.amount / 100.0

      payment_order = stripe.payment_orders.build(order_id: self.id, check_amount: stripe.total_amount)

      begin
        Payment.transaction do
          payment_order.confirm!
          stripe.save!
        end
        stripe
      rescue
        StripePayment.find_by(payment_uuid: charge.id)
      end
    else
      errors.add :uuid, 'error'
    end
  end


end
