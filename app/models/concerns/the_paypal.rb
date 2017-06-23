module ThePaypal
  PAYMENT =  PayPal::SDK::REST::DataTypes::Payment
  extend ActiveSupport::Concern

  included do
    attr_accessor :approve_url, :return_url, :cancel_url, :paypal_payment
    delegate :url_helpers, to: 'Rails.application.routes'
  end

  # first step
  def create_paypal_payment
    self.paypal_payment = PAYMENT.new(final_params)

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

  # 2 step: execute payment
  def paypal_execute(params)
    return unless self.payment_id
    self.paypal_payment ||= PAYMENT.find(self.payment_id)
    paypal_payment.execute(payer_id: params[:PayerID])
  end

  # 3 step: check result
  def paypal_result
    return unless self.payment_id
    self.paypal_payment ||= PAYMENT.find(self.payment_id)

    if paypal_payment.state == 'approved'
      trans = paypal_payment.transactions[0]

      paypal = PaypalPayment.new
      paypal.payment_uuid = trans.related_resources[0].sale.id
      paypal.total_amount = trans.amount.total

      payment_order = paypal.payment_orders.build(order_id: self.id, check_amount: paypal.total_amount)

      begin
        Payment.transaction do
          payment_order.save!
          paypal.save!
        end
        paypal
      rescue
        PaypalPayment.find_by(payment_uuid: trans.related_resources[0].sale.id)
      end
    else
      errors.add :uuid, paypal_payment.error.inspect
    end
  end

  def final_params
    if self.deposit_payment? && self.unpaid?
      result = origin_final_params
      result[:transactions][:amount][:total] = self.advance_payment_amount.to_money.exchange_to(self.currency).to_s
    else
      result = origin_final_params
    end
    result
  end

  def origin_final_params
    {
      intent: 'sale',
      payer: {
        payment_method: 'paypal'
      },
      redirect_urls: {
        return_url: self.return_url || url_helpers.execute_my_order_url(self.id),
        cancel_url: url_helpers.cancel_my_order_url(self.id)
      },
      transactions: {
        item_list: {
          items: items_params
        },
        amount: {
          total: items_params.sum { |i| i[:quantity] * i[:price].to_d },
          currency: self.currency.upcase
        },
        description: ''
      }
    }
  end

  def items_params
    if self.deposit_payment? && self.unpaid?
      deposit_items_params
    elsif self.part_paid?
      remain_items_params
    else
      origin_items_params
    end
  end

  def origin_items_params
    order_items.map do |item|
      {
        name: item.good.name,
        sku: item.good.sku,
        price: item.price.to_money.exchange_to(self.currency).to_s,
        currency: self.currency.upcase,
        quantity: item.number
      }
    end
  end

  def shipping_items_params
    {
      name: 'Shipping & Handling fee',
      sku: 'Shipping & Handling fee',
      price: (shipping_fee + handling_fee).to_money.exchange_to(self.currency).to_s,
      currency: self.currency.upcase,
      quantity: 1
    }
  end

  def deposit_items_params
    {
      name: 'Advance',
      sku: 'Advance',
      price: self.advance_payment_amount.to_money.exchange_to(self.currency).to_s,
      currency: self.currency.upcase,
      quantity: 1
    }
  end

  def remain_items_params
    {
      name: 'Advanced amount',
      sku: 'Advanced amount',
      price: self.unreceived_amount.to_money.exchange_to(self.currency).to_s,
      currency: self.currency.upcase,
      quantity: 1
    }
  end


end
