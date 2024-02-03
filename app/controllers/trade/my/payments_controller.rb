module Trade
  class My::PaymentsController < My::BaseController
    before_action :set_order, only: [:wxpay]
    before_action :set_payment, only: [:show, :edit, :update, :destroy]
    before_action :set_new_payment, only: [:new, :create]

    def index
      @payments = current_user.payments.page(params[:page])
    end

    def wallet

    end

    def next
      if @order.payment_status == 'all_paid'
        render 'paid' and return
      end
      url = @payment.url(params)

      if @payment.errors.blank?
        render 'create', locals: { url: url }
      else
        render 'create', locals: { url: url_for(controller: 'orders') }
      end
    end

    def paypal_execute
      if @order.paypal_execute(params)
        flase.now[:notice] = "Order[#{@order.uuid}] placed successfully"
        render 'create', locals: { return_to: board_order_url(@order) }
      else
        flase.now[:notice] =  @order.error.inspect
        render 'create', locals: { return_to: board_orders_url }
      end
    end

    def wxpay
      @payment = @order.to_payment
      #@payment.extra_params.merge! 'profit_sharing' => true
      @payment.seller_identifier = current_payee&.mch_id
      @payment.appid = current_wechat_user&.appid
      @payment.buyer_identifier = current_wechat_user&.uid
      @wxpay_order = @payment.js_pay

      if @wxpay_order['code'].present? || @wxpay_order.blank?
        respond_to do |format|
          format.html { render 'wxpay_err', status: :unprocessable_entity }
          format.json { render json: @wxpay_order.as_json, status: :unprocessable_entity }
        end
      else
        respond_to do |format|
          format.html { render 'wxpay' }
          format.json { render json: @wxpay_order.as_json }
        end
      end
    end

    # https://pay.weixin.qq.com/wiki/doc/api/native.php?chapter=6_5
    # 二维码有效期为2小时
    def wxpay_pc_pay
      @wxpay_order = @order.native_order(current_wechat_app)

      if @wxpay_order['code'].present? || @wxpay_order.blank?
        render 'wxpay_pay_err', status: :unprocessable_entity
      else
        @image_url = QrcodeHelper.data_url @wxpay_order['code_url']
        render 'wxpay_pc_pay'
      end
    end

    private
    def set_wallet_payment
      wallet_template = WalletTemplate.default_where(default_params).default.take
      if wallet_template && current_client
        @wallets = current_client.wallets.where(wallet_template_id: wallet_template.id)
      elsif wallet_template
        @wallets = current_user.wallets.where(wallet_template_id: wallet_template.id)
      else
        @wallets = Wallet.none
      end
      @payment = WalletPayment.where(wallet_id: @wallets.pluck(:id)).find(params[:id])
    end

    def set_payment
      @payment = Payment.find params[:id]
    end

    def set_new_payment
      @payment = Payment.new(payment_params)
    end

    def set_new_payment_with_payment_order
      @payment = @payment_order.build_payment(payment_params)
      @payment.user = current_user
    end

    def set_payment_order
      @payment_order = PaymentOrder.find params[:payment_order_id]
    end

    def set_order
      @order = Order.default_where(default_params).find params[:order_id]
    end

    def payment_params
      p = params.fetch(:payment, {}).permit(
        :type,
        :wallet_id,
        :total_amount,
        :proof,
        payment_orders_attributes: [:order_id, :payment_amount, :state]
      )
      p.merge! default_form_params
    end

  end
end
