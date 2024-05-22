module Trade
  class Agent::CartsController < Admin::CartsController
    include Controller::Agent
    before_action :set_contact, only: [:show]

    def index
      @carts = current_member.agent_carts.order(id: :desc).page(params[:page])
    end

    private
    def set_cart
      @cart = current_member.agent_carts.find(params[:id])
    end

    def set_contact
      @cart.contact || @cart.build_contact
    end

    def cart_params
      params.fetch(:cart, {}).permit(
        :address_id,
        :auto,
        contact_attributes: [:id, :identity, :name, :extra]
      )
    end

  end
end

