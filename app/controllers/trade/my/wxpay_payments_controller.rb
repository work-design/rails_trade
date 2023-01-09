module Trade
  class My::WxpayPaymentsController < My::BaseController
    before_action :set_payment, only: [:show, :edit, :update, :destroy]
    before_action :set_new_payment, only: [:new, :create]

    def index
      @payments = current_user.payments.where(type: 'Trade::WxpayPayment').page(params[:page])
    end

    def create
      #@payment.extra_params.merge! 'profit_sharing' => true
      @payment.app_payee = current_payee
      @payment.buyer_identifier = current_authorized_token.uid
      @wxpay_order = @payment.js_pay

      if @wxpay_order.blank? || @wxpay_order['code'].present?
        respond_to do |format|
          format.turbo_stream { render 'create_err' }
          format.html { render 'create_err' }
          format.json { render json: @wxpay_order.as_json, status: :unprocessable_entity }
        end
      else
        respond_to do |format|
          format.turbo_stream { render 'create_err' }
          format.html { render 'create' }
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
      @payment = current_user.payments.build(payment_params)
    end

    def set_new_payment_with_order
      @payment = @order.payments.build(payment_params)
      @payment.user = current_user
    end

    def payment_params
      p = params.fetch(:wxpay_payment, {}).permit(
        :type,
        :wallet_id,
        :total_amount,
        :proof
      )
      p.merge! default_form_params
      p.merge! type: 'Trade::WxpayPayment'
    end

  end
end
