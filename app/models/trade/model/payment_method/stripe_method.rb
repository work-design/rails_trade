module Trade
  module Model::PaymentMethod::StripeMethod
    extend ActiveSupport::Concern
    included do
      attr_accessor :token
      after_destroy_commit :remove
    end

    def retrieve
      customer = Stripe::Customer.retrieve account_num
      customer_info(customer)
    end

    def customer_info(customer)
      card = customer.sources.data[0]
      return {} unless card
      {
        description: customer.description,
        address_zip: card.address_zip,
        address_zip_check: card.address_zip_check,
        brand: card.brand,
        country: card.country,
        cvc_check: card.cvc_check,
        exp_month: card.exp_month,
        exp_year: card.exp_year,
        fingerprint: card.fingerprint,
        funding: card.funding,
        last4: card.last4
      }
    end

    def update_extra
      self.update extra: retrieve.to_h
    end

    def remove
      cu = Stripe::Customer.retrieve account_num
      cu.delete
    end

    def detective_save
      begin
        customer = Stripe::Customer.create(description: "buyer_id: #{payment_references.map { |i| i.buyer_id }}", source: self.token)
        self.account_num = customer.id
        self.extra = self.customer_info(customer)
      rescue Stripe::StripeError => ex
        self.errors.add :base, ex.message
      end

      self.verified = true
      if self.errors.blank?
        self.save
      else
        false
      end
    end

  end
end
