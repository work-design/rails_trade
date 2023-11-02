module Trade
  class Agent::ItemsController < Trade::Admin::ItemsController
    include Controller::Agent
    before_action :set_cart, only: [:create, :update, :destroy, :toggle, :trial, :untrial]
    before_action :set_cart_item, only: [:update, :destroy, :promote, :toggle, :finish]
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

    def set_cart_item
      @item = @cart.items.load.find params[:id]
    end

    def set_item
      @item = current_member.agent_items.find(params[:id])
    end

  end
end
