module Trade
  class Agent::ItemsController < Admin::ItemsController
    include Controller::Agent
    before_action :set_cart, only: [:create, :update, :destroy, :toggle, :trial, :untrial]
    before_action :set_cart_item, only: [:update, :destroy, :promote, :toggle, :finish]
    before_action :set_new_item, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! params.permit(:good_id, :desk_id)

      @items = current_member.agent_items.includes(:organ).default_where(q_params).page(params[:page])
    end

    private
    def set_address
      @address = current_user.principal_addresses.find params[:principal_address_id]
    end

    def set_cart
      @cart = Cart.get_cart(params, agent_id: current_member.id, **default_form_params)
      logger.debug "\e[35m  Cart:#{@cart.id}  \e[0m"
    end

    def set_cart_item
      @item = @cart.items.load.find params[:id]
    end

    def set_item
      @item = current_member.agent_items.find(params[:id])
    end

  end
end
