module Trade
  module Model::Payment::ApplePayment
    extend ActiveSupport::Concern

    included do
      has_many :refunds, class_name: 'AppleRefund'
    end

    def assign_detail(params)
      self.total_amount = params[:total_amount]
    end

    def apple_pay_result(receipt_data)
      return self if self.payment_status == 'all_paid'

      result = ApplePay.query receipt_data

      result['product_id'] == self.uuid
      result['amount'] = self.amount

      if result['trade_status'] == 'TRADE_SUCCESS'
        self.change_to_paid! type: 'Trade::ApplePayment', payment_uuid: result['transaction_id'], params: result
      else
        errors.add :base, result['msg']
      end
    end

  end
end
