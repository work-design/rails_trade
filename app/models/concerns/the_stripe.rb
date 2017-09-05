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
    @stripe_charge ||= Stripe::Charge.create(amount: (self.amount * 100).to_i, currency: self.currency, customer: stripe_payment_method.account_num)
  end

  def stripe_result
    trans = stripe_execute

    if trans.paid
      stripe = StripePayment.new
      stripe.payment_uuid = trans.id
      stripe.total_amount = trans.amount / 100.0

      payment_order = stripe.payment_orders.build(order_id: self.id, check_amount: stripe.total_amount)

      begin
        Payment.transaction do
          payment_order.confirm!
          stripe.save!
        end
        stripe
      rescue
        StripePayment.find_by(payment_uuid: trans.id)
      end
    else
      errors.add :uuid, 'error'
    end
  end


end
