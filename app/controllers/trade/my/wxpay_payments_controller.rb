module Trade
  class My::WxpayPaymentsController < My::BaseController
    before_action :set_payment, only: [:show, :edit, :update, :destroy]
    before_action :set_new_payment, only: [:new, :create]

    def index
      @payments = current_user.payments.where(type: 'Trade::WxpayPayment').page(params[:page])
    end

    def create
      @payment.save
    end

    def wxpay
      @payment = @order.to_payment
      #@payment.extra_params.merge! 'profit_sharing' => true
      @payment.user = current_user
      @payment.app_payee = current_payee
      @payment.buyer_identifier = current_authorized_token.uid
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
      @payment = WxpayPayment.new(payment_params)
    end

    def set_new_payment_with_order
      @payment = @order.payments.build(payment_params)
      @payment.user = current_user
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
