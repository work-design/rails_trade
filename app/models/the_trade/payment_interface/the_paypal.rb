module ThePaypal
  PAYMENT =  PayPal::SDK::REST::DataTypes::Payment
  extend ActiveSupport::Concern

  included do
    attr_accessor :approve_url, :return_url, :cancel_url, :paypal_payment
    delegate :url_helpers, to: 'Rails.application.routes'
  end

  def paypal_prepay
    self.paypal_payment = PAYMENT.new(paypal_params)

    result = paypal_payment.create
    if result
      self.payment_id = paypal_payment.id
      self.approve_url = paypal_payment.links.find{ |v| v.rel == 'approval_url' }.href
      self.save
    else
      self.errors.add :payment_id, paypal_payment.error.inspect
    end
    result
  end

  def paypal_execute(params)
    return unless self.payment_id
    self.paypal_payment ||= PAYMENT.find(self.payment_id)
    paypal_payment.execute(payer_id: params[:PayerID])

    paypal_record(paypal_payment)
  end

  def paypal_result
    return unless self.payment_id
    self.paypal_payment ||= PAYMENT.find(self.payment_id)

    paypal_record(paypal_payment)
  end

  def paypal_record(record)
    trans = record.transactions[0]

    if record.state == 'approved'
      paypal = PaypalPayment.find_by(payment_uuid: trans.related_resources[0].sale.id)
      return paypal if paypal

      paypal = PaypalPayment.new
      paypal.payment_uuid = trans.related_resources[0].sale.id
      paypal.total_amount = trans.amount.total

      payment_order = paypal.payment_orders.build(order_id: self.id, check_amount: paypal.total_amount)

      Payment.transaction do
        payment_order.confirm!
        paypal.save!
      end
      paypal
    else
      errors.add :uuid, record.error.inspect
    end
  end

  def paypal_params
    {
      intent: 'sale',
      payer: {
        payment_method: 'paypal'
      },
      redirect_urls: {
        return_url: self.return_url || url_helpers.paypal_execute_my_order_url(self.id),
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
