module Trade
  class Me::ItemsController < My::ItemsController
    include Controller::Me

    def index
      @items = current_member.items.includes(:good).order(id: :desc).page(params[:page])
    end

    private
    def set_cart
      @cart = Cart.get_cart(params, member_id: current_member.id, **default_form_params)
    end

    def set_item
      @item = current_member.items.find params[:id]
    end

  end
end

