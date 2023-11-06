module Trade
  class In::CartsController < Admin::CartsController

    def index
      @carts = current_organ.organ_carts.page(params[:page])
    end

    private
    def set_cart
      @cart = current_organ.organ_carts.find(params[:id])
    end

  end
end

