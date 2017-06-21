module ThePaypal
  extend ActiveSupport::Concern

  included do
    PAYMENT =  PayPal::SDK::REST::DataTypes::Payment
    attr_accessor :approve_url, :return_url, :cancel_url
    delegate :url_helpers, to: 'Rails.application.routes'
  end

  # first step
  def create_payment
    _payment = PAYMENT.new(final_params)
    self.payment_id = _payment.id

    if self.save
      self.approve_url = _payment.links.find{ |link| link.method == 'REDIRECT' }.try(:href)
    else
      errors.add :payment_id, _payment.error['message']
    end
    _payment
  end

  # second step
  def execute(params)
    return unless self.payment_id

    _payment = PAYMENT.find(self.payment_id)
    _payment.execute(payer_id: params[:PayerID])

    paypal = PaypalPayment.new
    if _payment.state == 'approved'
      trans = _payment.transactions[0]
      paypal.total_amount = trans.amount.total
      paypal.sale_id = trans.related_resources[0].sale.id
      paypal.save
    else
      errors.add :uuid, _payment.error.inspect
      false
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

  def insured_total_amount
    c_result = self.order_items.sum do |item|
      item.price.to_money.exchange_to(self.currency) * item.number
    end
    u_result = self.order_items.sum do |item|
      item.price.to_money * item.number
    end

    c_result += self.shipping_and_handling.to_money.exchange_to(self.currency)
    u_result += self.shipping_and_handling.to_money

    if self.deposit_payment? && self.unpaid?
      c_result = self.advance_payment_amount.to_money.exchange_to(self.currency)
      u_result = self.advance_payment_amount.to_money
    elsif self.deposit_payment? && self.part_paid?
      c_result = self.amount.to_money.exchange_to(self.currency) - self.received_amount.to_money.exchange_to(self.currency)
      u_result = (self.amount - self.received_amount).to_money
    end
    [c_result, u_result]
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
          total: insured_total_amount[0].to_s,
          currency: self.currency.upcase
        },
        description: 'Go-To Place to Buy Chemicals| ichemical.com'
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
    origin_items_params << {
      name: 'Advanced amount',
      sku: 'Advanced amount',
      price: (- self.received_amount).to_money.exchange_to(self.currency).to_s,
      currency: self.currency.upcase,
      quantity: 1
    }
  end


end
