module Trade
  class Admin::CartsController < Admin::BaseController
    before_action :set_cart, only: [:show, :edit, :update, :destroy, :actions]
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
      q_params = {
        good_type: nil,
        aim: nil
      }
      q_params.merge! default_params
      q_params.merge! params.permit(:good_type, :aim)

      @carts = Cart.includes(:user, :payment_strategy, :trade_items).where(member_id: nil).where.not(user_id: nil).where(q_params).order(id: :desc).page(params[:page])
    end

    def user_show
      q_params = {
        user_id: params[:user_id]
      }
      q_params.merge! default_params

      @user = Auth::User.find params[:user_id]
      @carts = Cart.includes(:payment_strategy, :trade_items).default_where(q_params)
    end

    def create

    end

    def add

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
