module Trade
  class Admin::CartsController < Admin::BaseController
    before_action :set_cart, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_payment_strategies, only: [:new, :create, :edit, :update]
    before_action :set_purchase, only: [:show]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:id)

      @carts = Cart.includes(:user, :member, :member_organ, :payment_strategy, :items).where.not(user_id: nil).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def member_organ
      @member_organ_ids = Trade::Cart.select(:member_organ_id).distinct.where.not(member_organ_id: nil).page(params[:page])
      @carts = Cart.where(member_organ_id: @member_organ_ids.pluck(:member_organ_id)).includes(:member_organ)
    end

    def user
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:good_type, :aim)

      @carts = Cart.includes(:user, :payment_strategy, :items).where(member_id: nil).where.not(user_id: nil).where(q_params).order(id: :desc).page(params[:page])
    end

    def user_show
      q_params = {
        user_id: params[:user_id]
      }
      q_params.merge! default_params
      q_params.merge! params.permit(:aim, :good_type)

      @user = Auth::User.find params[:user_id]
      @carts = Cart.includes(:payment_strategy, :items).where(member_id: nil).default_where(q_params)
    end

    def show
      q_params = {}

      @items = @cart.items.includes(produce_plan: :scene).default_where(q_params).order(id: :asc).page(params[:page])
      @checked_ids = @cart.items.default_where(q_params).unscope(where: :status).status_checked.pluck(:id)
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
      @cart.compute_amount! unless @cart.fresh
    end

    def set_payment_strategies
      @payment_strategies = PaymentStrategy.default_where(default_params)
    end

    def set_purchase
      effective_ids = @cart.cards.effective.pluck(:card_template_id)
      min_grade = Trade::CardTemplate.default_where(default_params).minimum(:grade)
      @card_templates = Trade::CardTemplate.default_where(default_params).where.not(id: effective_ids).where(grade: min_grade)
    end

    def cart_params
      params.fetch(:cart, {}).permit(
        :payment_strategy_id,
        :deposit_ratio
      )
    end

    def _prefixes
      super do |pres|
        if ['show'].include?(params[:action])
          pres + ['trade/my/carts/_show', 'trade/my/carts/_base']
        else
          pres
        end
      end
    end

  end
end
