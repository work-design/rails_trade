module Trade
  class In::ItemsController < Admin::ItemsController
    include Controller::In
    before_action :set_cart, only: [
      :show, :edit, :update, :destroy, :actions,
      :promote, :toggle, :finish, :edit_price, :update_price, :create, :cost
    ]
    before_action :set_item, only: [
      :show, :edit, :update, :destroy, :actions,
      :promote, :toggle, :finish, :edit_price, :update_price
    ]
    before_action :set_new_item, only: [:create, :cost]

    def cost
      @item.single_price = @item.good.cost
      @item.save
    end

    def update_price
      @item.single_price = params.fetch(:item, {})[:single_price]
      @item.save
    end

    def destroy
      @cart.items.destroy(@item)
    end

    private
    def set_cart
      @cart = Cart.get_cart(params, member_organ_id: current_organ.id)
    end

    def set_item
      @item = current_organ.organ_items.find params[:id]
    end

    def item_params
      params.fetch(:item, {}).permit(
        :number,
        :organ_id,
        :note,
        :desk_id,
        :current_cart_id
      )
    end

  end
end

