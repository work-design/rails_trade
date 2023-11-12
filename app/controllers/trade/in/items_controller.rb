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
      if params[:current_cart_id].present?
        @cart = Cart.find params[:current_cart_id]
      elsif item_params[:current_cart_id].present?
        @cart = Cart.find item_params[:current_cart_id]
      else
        options = { agent_id: current_member.id }
        options.merge! default_form_params
        options.merge! user_id: nil, member_id: nil, client_id: nil
        @cart = Trade::Cart.where(options).find_or_create_by(good_type: params[:good_type], aim: params[:aim].presence || 'use')
      end
    end

    def set_cart_item
      @item = @cart.organ_items.load.find params[:id]
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

