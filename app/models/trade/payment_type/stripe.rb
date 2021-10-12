module Trade
  module PaymentType::Stripe

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
      rescue Stripe::StripeError, Stripe::CardError => ex
        self.errors.add :base, ex.message
      end
      self
    end

    def stripe_result
      return self if self.payment_status == 'all_paid'

      if self.payment_id.present?
        charge = Stripe::Charge.retrieve(self.payment_id)

        if charge.paid && !charge.refunded
           self.change_to_paid! type: 'Trade::StripePayment', payment_uuid: charge.id, params: charge
        else
          errors.add :uuid, 'error'
        end

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
end
