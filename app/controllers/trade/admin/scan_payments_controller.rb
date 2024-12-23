module Trade
  class Admin::ScanPaymentsController < Admin::PaymentsController
    before_action :set_new_scan_payment, only: [:new]
    before_action :set_new_payment, only: [:create]
    skip_before_action :require_org_member, only: [:new, :create] if whether_filter(:require_org_member)
    skip_before_action :require_role, only: [:new, :create] if whether_filter(:require_role)

    def index
      q_params = {}
      q_params.merge! default_params

      @scan_payments = ScanPayment.default_where(q_params).order(id: :desc).page(params[:page])
    end

    def create
      @scan_payment.micro_pay!(auth_code: auth_code, spbill_create_ip: request.remote_ip)
    end

    def batch
      @payment = ScanPayment.init_with_order_ids params[:ids].split(',')
    end

    private
    def set_new_scan_payment
      @scan_payment = ScanPayment.new(scan_payment_params)
    end

    def set_new_payment
      if auth_code.start_with?('25', '26', '27', '28', '29', '30', 'fp') && current_alipay_app
        @scan_payment = AlipayPayment.new(scan_payment_params)
        @scan_payment.appid = current_alipay_app.appid
      elsif current_payee
        @scan_payment = ScanPayment.new(scan_payment_params)
        @scan_payment.seller_identifier = current_payee.mch_id
        @scan_payment.appid = current_payee.payee_apps[0]&.appid
      end
      @scan_payment.operator = current_user
      @scan_payment
    end

    def auth_code
      params[:result].split(',')[-1]
    end

    def current_alipay_app
      return @current_alipay_app if defined? @current_alipay_app
      @current_alipay_app = Alipay::App.default_where(default_params).take
    end

    def scan_payment_params
      p = params.fetch(:scan_payment, {}).permit(
        :total_amount,
        payment_orders_attributes: [:order_id, :order_amount, :state]
      )
      p.merge! default_form_params
    end

  end
end
