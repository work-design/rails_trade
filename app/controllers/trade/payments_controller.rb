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
      notify_params = WxPay::Cipher.decrypt_notice encrypted_params['resource'], key: current_wechat_app.key_v3

      @order = Order.find_by(uuid: notify_params['out_trade_no'])
      result = nil

      if @order #&& WxPay::Sign.verify?(notify_params, key: wechat_app.key)
        result = @order.change_to_paid! params: notify_params, payment_uuid: notify_params['transaction_id'], type: 'Trade::WxpayPayment'
      end

      if result
        render xml: { return_code: 'SUCCESS' }.to_xml(root: 'xml', dasherize: false)
      else
        render xml: { return_code: 'FAIL', return_msg: '签名失败' }.to_xml(root: 'xml', dasherize: false), status: :bad_request
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
