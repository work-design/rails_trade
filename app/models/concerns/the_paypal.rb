module ThePaypal
  extend ActiveSupport::Concern

  included do

  end

  def final_params
    if order.deposit_payment? && order.unpaid?
      result = origin_final_params
      result[:transactions][:amount][:total] = order.advance_payment_amount.to_money.exchange_to(self.currency).to_s
    else
      result = origin_final_params
    end
    result
  end

  def insured_total_amount
    c_result = self.order.order_items.sum do |item|
      item.price.to_money.exchange_to(self.currency) * item.number
    end
    u_result = self.order.order_items.sum do |item|
      item.price.to_money * item.number
    end

    c_result += order.shipping_and_handling.to_money.exchange_to(self.currency)
    u_result += order.shipping_and_handling.to_money

    if order.deposit_payment? && order.unpaid?
      c_result = order.advance_payment_amount.to_money.exchange_to(self.currency)
      u_result = order.advance_payment_amount.to_money
    elsif order.deposit_payment? && order.part_paid?
      c_result = order.amount.to_money.exchange_to(self.currency) - order.received_amount.to_money.exchange_to(self.currency)
      u_result = (order.amount - order.received_amount).to_money
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
        return_url: self.return_url || url_helpers.execute_orders_url(order_id: self.order_id),
        cancel_url: url_helpers.cancel_orders_url(order_id: self.order_id)
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
    if order.deposit_payment? && order.unpaid?
      deposit_items_params
    elsif order.deposit_payment? && order.part_paid?
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
      price: shipping_and_handling.to_money.exchange_to(self.currency).to_s,
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
      price: (- order.received_amount).to_money.exchange_to(self.currency).to_s,
      currency: self.currency.upcase,
      quantity: 1
    }
  end


end
