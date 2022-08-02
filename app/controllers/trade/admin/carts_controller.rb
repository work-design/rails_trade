module Trade
  class Admin::CartsController < Admin::BaseController
    before_action :set_cart, only: [:show, :destroy]
    before_action :set_payment_strategies, only: [:new, :create, :edit, :update]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:id)

      @carts = Cart.includes(:user, :member, :member_organ, :payment_strategy, :trade_items).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def member_organ
      @carts = Cart.select(:member_organ_id).distinct.where.not(member_organ_id: nil).includes(:member_organ).page(params[:page])
    end

    def user
      q_params = {}
      q_params.merge! default_params

      @carts = Cart.includes(:user, :payment_strategy, :trade_items).where(member_id: nil).where.not(user_id: nil).default_where(q_params).page(params[:page])
    end

    def new
      @cart_serve = @cart_item.cart_serves.find_or_initialize_by(serve_id: params[:serve_id])
      @serve_charge = @cart_item.get_charge(@cart_serve.serve)
    end

    def create
      @cart_item_serve = @cart_item.cart_item_serves.find_or_initialize_by(serve_id: cart_item_serve_params[:serve_id])
      @cart_item_serve.assign_attributes cart_item_serve_params

      @serve_charge = @cart_item.get_charge(@cart_item_serve.serve)
      @serve_charge.subtotal = @cart_item_serve.price

      if @cart_item_serve.save

      else
        render :new
      end
    end

    def add
      @cart_item_serve = @cart_item.cart_item_serves.find_or_initialize_by(serve_id: params[:serve_id])

      @serve_charge = @cart_item.get_charge(@cart_item_serve.serve)
      @cart_item_serve.price = @serve_charge.default_subtotal
      @cart_item_serve.save
    end

    def orders
      @orders = @buyer.orders.includes(crm_performs: :manager).to_pay.order(overdue_date: :asc).page(params[:page])
      payment_method_ids = @buyer.payment_references.pluck(:payment_method_id)
      @payments = Payment.where(payment_method_id: payment_method_ids, state: ['init', 'part_checked'])
    end

    private
    def set_cart
      @cart = Cart.find params[:id]
    end

    def set_payment_strategies
      @payment_strategies = PaymentStrategy.default_where(default_params)
    end

    def cart_params
      params.fetch(:cart, {}).permit(
        :payment_strategy_id,
        :deposit_ratio
      )
    end

  end
end
