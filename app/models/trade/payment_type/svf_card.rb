module Trade
  module PaymentType::SvfCard

    def card_pay
      if payment_status == 'all_paid'
        return { success: false, message: '已经支付过了，不要重复支付' }
      end

      self.class.transaction do
        params = {
          total_amount: self.unreceived_amount,
          adjust_amount: self.amount,
          user_id: self.user_id
        }

        payment = self.change_to_paid!(type: 'Trade::CardPayment', payment_uuid: UidHelper.nsec_uuid, params: params)
        { success: true, payment: payment }
      end
    rescue ActiveRecord::RecordInvalid => e
      return { success: false, message: e.message }
    end

  end
end
