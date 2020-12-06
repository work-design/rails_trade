class Trade::My::AdvancesController < Trade::My::BaseController
  skip_before_action :require_login, only: [:index]

  def index
    platform = request.headers['OS'].to_s.downcase

    @advances = Advance.verified.order(price: :asc)
    @advances.each {|advance| advance.extra = { platform: platform } } # 用以计算advance.final_price
  end

  def order
    @advance = Advance.find(params[:id])

    @order = @advance.generate_order!(buyer: current_user,
      amount: @advance.final_price
    )

    if params[:payment_method] == 'wxpay_app'
      @wxpay_order = @order.wxpay_app_pay
    end
  end

  # 当IOS客户端IAP(应用内购买)成功后，客户端上传支付凭证
  # 1005, used receipt
  # 1006
  def apple_pay
    if !Rails.env.production?
      r = ApplePay.verify(params['receipt-data'], true)
    else
      r = ApplePay.detect_verify(params['receipt-data'])
    end

    if r['status'] == 0
      @invoices = r.dig('receipt', 'in_app')
      @invoices.map do |invoice|
        product_id = invoice.fetch('product_id')
        uuid = invoice.fetch('transaction_id')

        advance = Advance.find_by(apple_product_id: product_id)
        order = advance.generate_order!(buyer: current_user)
        begin
          result = order.change_to_paid! params: { total_amount: order.amount }, type: 'ApplePayment', payment_uuid: uuid
        rescue
          result = false
        ensure
          if order.payment_id_taken?
            result = true
          end
        end
        invoice['checked'] = !!result
      end
      @invoices
    else
      result = false
    end

    if @invoices
      render json: { invoices: @invoices.map{ |i| i.slice('transaction_id', 'checked') } }
    else
      render json: { message: '核销失败！' }, status: :bad_request
    end
  end

end
