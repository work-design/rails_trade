module Trade
  class My::OrdersController < My::BaseController
    before_action :set_order, only: [
      :show, :edit, :update, :refund, :payment_types, :payment_type, :wait, :destroy, :cancel,
      :paypal_pay, :stripe_pay, :alipay_pay, :paypal_execute, :wxpay_pay, :wxpay_pc_pay
    ]
    before_action :set_cart, only: [:new]
    before_action :set_payment_strategies, only: [:blank]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! client_params
      q_params.merge! params.permit(:id, :payment_type, :payment_status, :state)

      @orders = Order.includes(:trade_items).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def new
      @order = current_user.orders.build(current_cart_id: params[:current_cart_id])
    end

    def blank
      @order = current_user.orders.build(order_params)
      @order.address_id ||= params[:address_id]
      @order.trade_items.build
      @order.compute_promote

      if params[:commit].present? && @order.save
        render 'blank'
      else
        render 'blank'
      end
    end

    def create_blank
      @order = current_user.orders.build(order_params)

      if params[:commit].present? && @order.save
        render 'create_blank'
      else
        render 'blank'
      end
    end

    def refresh
      @order = current_user.orders.build(myself: true)
      @order.assign_attributes order_params
    end

    def trial
      @order = current_user.orders.build(order_params)
    end

    def create
      @order = current_user.orders.build(order_params)
      @order.sync_from_current_cart

      if @order.save
        render 'create'
      else
        render :new, locals: { model: @order }, status: :unprocessable_entity
      end
    end

    def add
      @order = current_user.orders.build
      @order.trade_items.build(
        good_id: params[:good_id],
        good_type: params[:good_type],
        extra: params.except(:good_id, :good_type, :member_id, :business, :namespace, :controller, :action, :authenticity_token, :button)
      )
      @order.valid?
      @order.sum_amount
    end

    def direct
      @order = current_user.orders.build(order_params)

      if @order.save
        render :direct
      else
        render :add, locals: { model: @order }, status: :unprocessable_entity
      end
    end

    # todo part paid case
    def wait
      if @order.all_paid?
        render 'show'
      else
        render 'wait'
      end
    end

    def payment_types
    end

    def stripe_pay
      if @order.payment_status != 'all_paid'
        @order.stripe_charge(params)
      end

      if @order.errors.blank?
        render 'create', locals: { return_to: @order.approve_url }
      else
        render 'create', locals: { return_to: board_orders_url }
      end
    end

    def alipay_pay
      if @order.payment_status != 'all_paid'
        render 'create', locals: { return_to: @order.alipay_prepay_url }
      else
        render 'create', locals: { return_to: board_orders_url }
      end
    end

    def paypal_pay
      if @order.payment_status != 'all_paid'
        result = @order.paypal_prepay
        render 'create', locals: { return_to: result }
      else
        render 'create', locals: { return_to: board_orders_url }
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

    def wxpay_pay
      @wxpay_order = @order.wxpay_order(current_wechat_app)

      if @wxpay_order['code'].present? || @wxpay_order.blank?
        render 'wxpay_pay_err', status: :unprocessable_entity
      else
        render 'wxpay_pay'
      end
    end

    def refund
      @order.apply_for_refund
    end

    def cancel
      @order.state = 'canceled'
      @order.save
    end

    private
    def current_wechat_app
      if params[:appid]
        Wechat::App.find_by appid: params[:appid]
      else
        super
      end
    end

    def set_cart
      @cart = Cart.find params[:current_cart_id]
    end

    def set_order
      @order = Order.find(params[:id])
    end

    def set_payment_strategies
      @payment_strategies = PaymentStrategy.limit(5)
    end

    def order_params
      p = params.fetch(:order, {}).permit(
        :quantity,
        :payment_id,
        :payment_type,
        :address_id,
        :note,
        :current_cart_id,
        trade_items_attributes: {}
      )
      p.merge! default_form_params
    end

  end
end
