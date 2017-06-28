class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_order

  def alipay_notify
    @order = Order.find_by(uuid: params[:out_trade_no])

    notify_params = alipay_params.except(*request.path_parameters.keys)
    result = nil

    if Alipay::Notify.verify?(notify_params)
      payment = @order.payments.build merge(type: 'AlipayWeb')
      payment_order = paypal.payment_orders.build(order_id: self.id, check_amount: payment.total_amount)
      result = payment.save_detail!(notify_params)
    end

    if result
      render text: 'success', layout: false
    else
      render text: 'fail', status: :bad_request, layout: false
    end
  end

  def wxpay_notify
    notify_params = Hash.from_xml(request.body.read)['xml']
    result = nil
    @order = CustomerOrder.find_by(customer_order_no: notify_params['out_trade_no'])

    if WxPay::Sign.verify?(notify_params)
      notify_params = notify_params.merge(type: 'WxpayJsapi')
      result = @order.change_to_paid!(notify_params)
    end

    if result
      render xml: { return_code: 'SUCCESS' }.to_xml(root: 'xml', dasherize: false)
    else
      render xml: { return_code: 'FAIL', return_msg: '签名失败' }.to_xml(root: 'xml', dasherize: false),
             status: :bad_request
    end
  end

  def wxpay_result
    result = @order.wxpay_result
    render json: result
  end

  def paypal_result
    @order.update payment_id: params[:payment_id]
    result = @order.paypal_result
    render json: result.as_json(only: [:id, :total_amount, :type, :payment_uuid, :currency])
  end

  private
  def set_order
    @order = Order.find(params[:order_id])
  end

  def alipay_params
    params.permit!
  end

end
