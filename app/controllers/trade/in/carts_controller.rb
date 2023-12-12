module Trade
  class In::CartsController < Admin::CartsController

    def index
      @carts = current_organ.member_carts.page(params[:page])
    end

    def show
      q_params = {}

      @items = @cart.organ_items.includes(produce_plan: :scene).default_where(q_params).order(id: :asc).page(params[:page])
    end

    private
    def set_cart
      @cart = current_organ.member_carts.find(params[:id])
    end

  end
end

