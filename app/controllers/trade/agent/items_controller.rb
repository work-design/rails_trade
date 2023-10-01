module Trade
  class Agent::ItemsController < Trade::My::ItemsController
    before_action :set_new_item, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! params.permit(:good_id)

      @items = current_member.agent_items.includes(:organ).default_where(q_params).page(params[:page])
    end

    private
    def set_address
      @address = current_user.principal_addresses.find params[:principal_address_id]
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

    def set_new_item
      options = { member_id: current_member.id }
      options.merge! params.permit(:good_type, :good_id, :member_id, :number, :produce_on, :scene_id)

      @item = Item.new(**options.to_h.symbolize_keys)
    end

    def set_item
      @item = Trade::Item.find(params[:id])
    end

  end
end
