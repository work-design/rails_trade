module Trade
  class PaymentsController < BaseController
    skip_before_action :verify_authenticity_token
    before_action :set_order, only: [:result]

    def alipay_notify
      notify_params = params.permit!.except(*request.path_parameters.keys).to_h

      @order = Order.find_by(uuid: params[:out_trade_no])
      result = nil

      if Alipay2::Notify.verify?(notify_params)
        result = @order.change_to_paid! params: notify_params, payment_uuid: notify_params['trade_no'], type: 'AlipayPayment'
      end

      if result
        render plain: 'success'
      else
        render plain: 'failure', status: :bad_request
      end
    end

    def apple_notify
      @order = Order.find_by(uuid: params[:order_uuid])
      notify_params = params.permit!
      notify_params.merge! amount: @order.amount

      result = nil
      if ApplePay.verify?
        result = @order.changed_to_paid! params: notify_params, type: 'ApplePayment'
      end

      if result
        render json: { code: 200 }
      else
        render json: { }, status: :bad_request
      end
    end

    def wxpay_notify
      encrypted_params = JSON.parse(request.body.read)
      payee = Wechat::PartnerPayee.find_by(mch_id: params[:mch_id]) || Wechat::MchPayee.find_by(mch_id: params[:mch_id])
      notify_params = WxPay::Cipher.decrypt_notice encrypted_params['resource'], key: payee.key_v3
      logger.debug "\e[35m  #{notify_params}  \e[0m"

      if notify_params['out_trade_no'].start_with?('PAY')
        @payment = Payment.find_by(payment_uuid: notify_params['out_trade_no'])
      else
        uuid = notify_params['out_trade_no'].split('_')[0] || notify_params['out_trade_no']
        @order = Order.find_by(uuid: uuid)
        @payment = @order.to_payment(type: 'Trade::WxpayPayment', payment_uuid: notify_params['transaction_id'], total_amount: notify_params.dig('amount', 'total').to_i / 100.0)
        @payment.checked_amount = @payment.total_amount
      end
      @payment.confirm(notify_params)

      if @payment.save
        render json: { code: 'SUCCESS', message: '处理成功' }
      else
        render json: { code: 'FAIL', message: '签名失败' }, status: :bad_request
      end
    end

    def notify
      @notify_params = params.permit!.except(*request.path_parameters.keys).to_h
    end

    def result
      @order.change_to_paid! type: 'HandPayment'
      render json: @order.as_json(only: [:id, :amount, :received_amount, :currency, :payment_status])
    end

    private
    def set_order
      @order = Order.find(params[:order_id])
    end

  end
end
