module Trade
  class Mem::CartsController < My::CartsController
    if whether_filter :require_client
      skip_before_action :require_client, only: [:list]
    end

    def addresses
      @addresses = current_client.addresses.order(id: :asc)
    end

    private
    def set_cart
      options = {}
      options.merge! default_form_params
      options.merge! member_id: current_user.id

      @cart = Cart.where(options).unscope(where: :organ_id).find params[:id]
      @cart.compute_amount! unless @cart.fresh
    end

    def cart_params
      params.fetch(:cart, {}).permit(
        :address_id,
        :auto
      )
    end

  end
end
