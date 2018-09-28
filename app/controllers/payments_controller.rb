class PaymentsController < ApplicationController
  include RailsCommonApi
  skip_before_action :verify_authenticity_token

  def alipay_notify
    notify_params = params.permit!.except(*request.path_parameters.keys).to_h

    @order = Order.find_by(uuid: params[:out_trade_no])
    result = nil

    if Alipay::Notify.verify?(notify_params)
      result = @order.change_to_paid! notify_params.merge(type: 'AlipayPayment')
    end

    if result
      render plain: 'success'
    else
      render plain: 'failure', status: :bad_request
    end
  end

  def wxpay_notify
    notify_params = Hash.from_xml(request.body.read)['xml']

    @order = Order.find_by(uuid: notify_params['out_trade_no'])
    result = nil

    if WxPay::Sign.verify?(notify_params)
      result = @order.change_to_paid! notify_params.merge(type: 'WxpayPayment')
    end

    if result
      render xml: { return_code: 'SUCCESS' }.to_xml(root: 'xml', dasherize: false)
    else
      render xml: { return_code: 'FAIL', return_msg: '签名失败' }.to_xml(root: 'xml', dasherize: false),
             status: :bad_request
    end
  end

  def notify
    @notify_params = params.permit!.except(*request.path_parameters.keys).to_h
  end

  def result
    @order = Order.find(params[:order_id])
    @order.change_to_paid!
    render json: @order.as_json(only: [:id, :amount, :received_amount, :currency, :payment_status])
  end

end
