module Trade
  class In::ItemsController < Admin::ItemsController
    include Controller::In
    before_action :set_cart, only: [
      :show, :edit, :update, :destroy, :actions,
      :promote, :toggle, :finish, :edit_number, :edit_price, :update_price, :create, :cost
    ]
    before_action :set_cart_item, only: [:update, :destroy, :toggle]
    before_action :set_item, only: [
      :show, :edit, :actions, :promote, :finish, :edit_number, :edit_price, :update_price
    ]
    before_action :set_new_item, only: [:create, :cost]

    def cost
      @item.single_price = @item.good.cost
      @item.save
    end

    def update_price
      @item.assign_attributes item_number_params
      @item.save
    end

    def destroy
      @cart.items.destroy(@item)
    end

    private
    def set_cart
      @cart = Cart.get_cart(params, member_organ_id: current_organ.id, purchasable: true)
    end

    def set_item
      @item = Item.where(member_organ_id: current_organ.id).find params[:id]
    end

    def item_number_params
      params.permit(
        :number,
        :single_price
      )
    end

    def item_params
      params.permit(
        :good_type,
        :good_id,
        :purchase_id,
        :number,
        :organ_id,
        :provide_id,
        :note,
        :desk_id,
        :current_cart_id
      )
    end

  end
end

