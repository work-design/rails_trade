module Trade
  class In::ItemsController < Admin::ItemsController
    include Controller::In
    before_action :set_cart, :set_item, only: [
      :show, :edit, :update, :destroy, :actions,
      :promote, :toggle, :finish, :edit_price, :update_price, :edit_assign
    ]
    before_action :set_cart, :set_new_item, only: [:create, :cost]

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
    # def set_item
    #   @item = current_organ.organ_items.find params[:id]
    # end

    def set_cart
      if current_cart
        @cart = current_cart
      else
        options = { member_organ_id: current_organ.id }
        options.merge! user_id: nil, member_id: nil
        options.merge! client_id: nil, contact_id: nil
        @cart = Trade::Cart.where(options).find_or_create_by(good_type: params[:good_type], aim: 'use')
      end
    end

    def item_params
      params.fetch(:item, {}).permit(
        :number,
        :note,
        :desk_id,
        :current_cart_id
      )
    end

  end
end

