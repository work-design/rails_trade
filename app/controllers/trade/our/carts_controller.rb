module Trade
  class Our::CartsController < My::CartsController

    def show
      q_params = {
        status: ['init', 'checked']
      }
      if params[:address_id].present?
        current_cart.update address_id: params[:address_id]
      end

      @items = current_cart.trade_items.includes(produce_plan: :scene).default_where(q_params).order(id: :asc).page(params[:page])
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

    def cart_params
      params.fetch(:cart, {}).permit(
        :address_id,
        :auto
      )
    end

  end
end
