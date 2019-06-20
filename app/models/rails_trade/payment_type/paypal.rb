module RailsTrade::PaymentType::Paypal

  def paypal_prepay
    paypal_payment = PayPal::SDK::REST::DataTypes::Payment.new(paypal_params)

    result = paypal_payment.create
    if result
      self.update(payment_id: paypal_payment.id)
    else
      self.errors.add :payment_id, paypal_payment.error.inspect
    end
    paypal_payment.links.find{ |v| v.rel == 'approval_url' }.href
  end

  def paypal_execute(params)
    return unless self.payment_id
    paypal_payment = PayPal::SDK::REST::DataTypes::Payment.find(self.payment_id)
    paypal_payment.execute(payer_id: params[:PayerID])

    paypal_record(paypal_payment)
  end

  def paypal_result
    return self if self.payment_status == 'all_paid'

    return unless self.payment_id
    paypal_payment ||= PayPal::SDK::REST::DataTypes::Payment.find(self.payment_id)
    trans = paypal_payment.transactions[0]

    if paypal_payment.state == 'approved'
      self.change_to_paid! type: 'PaypalPayment', payment_uuid: trans.related_resources[0].sale.id, params: trans
    else
      errors.add :base, paypal_payment.error.inspect
    end
  end

  def paypal_params
    {
      intent: 'sale',
      payer: {
        payment_method: 'paypal'
      },
      redirect_urls: {
        return_url: url_helpers.paypal_execute_my_order_url(self.id),
        cancel_url: url_helpers.cancel_my_order_url(self.id)
      },
      transactions: {
        item_list: {
          items: paypal_items_params
        },
        amount: {
          total: self.unreceived_amount,
          currency: self.currency.upcase
        },
        description: ''
      }
    }
  end

  def paypal_items_params
    items = order_items.map do |item|
      {
        name: item.good.name,
        sku: item.good.sku,
        price: item.good.price.to_money.exchange_to(self.currency).to_s,
        currency: self.currency.upcase,
        quantity: item.number
      }
    end
    serves = order_serves.map do |item|
      {
        name: item.serve.name,
        sku: item.serve.id,
        price: item.price.to_money.exchange_to(self.currency).to_s,
        currency: self.currency.upcase,
        quantity: 1
      }
    end
    items + serves
  end

end
