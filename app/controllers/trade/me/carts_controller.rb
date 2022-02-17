module Trade
  class Me::CartsController < My::CartsController

    def show
      q_params = {
        status: ['init', 'checked']
      }
      if params[:address_id].present?
        current_cart.update address_id: params[:address_id]
      end

      @trade_items = current_cart.trade_items.includes(produce_plan: :scene).default_where(q_params).page(params[:page])
      @checked_ids = current_cart.trade_items.default_where(q_params).unscope(where: :status).checked.pluck(:id)
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

    def self.local_prefixes
      [controller_path, 'trade/me/base', 'me']
    end

  end
end
