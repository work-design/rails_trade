module Trade
  class In::CartsController < My::CartsController

    private
    def set_cart
      @cart = current_organ.organ_carts.find(params[:id])
    end

  end
end

