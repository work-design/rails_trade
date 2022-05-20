module Trade
  class My::CartsController < My::BaseController
    before_action :set_cart, only: [:show, :update]
    before_action :set_purchase, only: [:show, :invest, :rent]

    def show
      q_params = {
        good_type: RailsTrade.config.cart_models
      }

      @trade_items = current_cart.trade_items.includes(produce_plan: :scene).default_where(q_params).order(id: :asc).page(params[:page])
      @checked_ids = current_cart.trade_items.default_where(q_params).unscope(where: :status).status_checked.pluck(:id)
    end

    def invest
      q_params = {
        good_type: RailsTrade.config.cart_models,
        aim: 'invest'
      }

      @trade_items = current_cart.trade_items.default_where(q_params).order(id: :asc).page(params[:page])
      @checked_ids = current_cart.trade_items.default_where(q_params).unscope(where: :status).status_checked.pluck(:id)
    end

    def rent
      q_params = {
        good_type: RailsTrade.config.cart_models,
        aim: 'rent'
      }

      @trade_items = current_cart.trade_items.default_where(q_params).order(id: :asc).page(params[:page])
      @checked_ids = current_cart.trade_items.default_where(q_params).unscope(where: :status).status_checked.pluck(:id)
    end

    def addresses
      @addresses = current_user.addresses.order(id: :asc)
    end

    def list
      @members = current_user.members.includes(:organ)
    end

    def promote
    end

    private
    def set_cart
      @cart = current_cart
    end

    def set_purchase
      effective_ids = current_cart.cards.effective.pluck(:card_template_id)
      min_grade = Trade::CardTemplate.default_where(default_params).minimum(:grade)
      @card_templates = Trade::CardTemplate.default_where(default_params).where.not(id: effective_ids).where(grade: min_grade)
    end

    def cart_params
      params.fetch(:cart, {}).permit(
        :address_id,
        :auto
      )
    end

  end
end
