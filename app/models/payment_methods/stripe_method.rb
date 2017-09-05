class StripeMethod < PaymentMethod


  def retrieve
    customer = Stripe::Customer.retrieve account_num
    customer_info(customer)
  end

  def customer_info(customer)
    card = customer.sources.data[0]
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

  end

end



