module RailsTrade::PaymentType::ApplePay

  def apple_pay_result(receipt_data)
    return self if self.payment_status == 'all_paid'

    result = ApplePay.query receipt_data

    result['product_id'] == self.uuid
    result['amount'] = self.amount

    if result['trade_status'] == 'TRADE_SUCCESS'
      self.change_to_paid! type: 'ApplePayment', payment_uuid: result['transaction_id'], params: result
    else
      errors.add :base, result['msg']
    end
  end

end
