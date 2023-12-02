module Trade
  class In::ItemsController < Admin::ItemsController
    include Controller::In
    before_action :set_cart, only: [:create, :update, :destroy, :toggle, :trial, :untrial]
    before_action :set_item, only: [:show]
    before_action :set_new_item, only: [:create, :cost]
    before_action :set_cart_item, only: [:update, :destroy, :promote, :toggle, :finish]

    def cost
      @item.single_price = @item.good.cost
      @item.save
    end

    def destroy
      @cart.items.destroy(@item)
    end

    private
    def set_item
      @item = current_organ.organ_items.find params[:id]
    end

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

    def set_cart_item
      @item = @cart.organ_items.load.find params[:id]
    end

    def item_params
      params.fetch(:item, {}).permit(
        :number,
        :note,
        :desk_id
      )
    end

  end
end

