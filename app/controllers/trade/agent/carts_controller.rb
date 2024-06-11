module Trade
  class Agent::CartsController < Admin::CartsController
    include Controller::Agent
    before_action :set_cart, only: [:show, :edit, :update, :destroy, :actions, :bind]
    before_action :set_contact, only: [:show]
    before_action :set_purchase, only: [:show]

    def index
      @carts = current_member.agent_carts.order(id: :desc).page(params[:page])
    end

    def bind
      contact = Crm::Contact.default_where(default_params).find_by(identity: cart_params.dig('contact_attributes', 'identity'))
      options = { agent_id: current_member.id }
      options.merge! default_params
      options.merge! client_id: @contact.client_id, contact_id: @contact.id
      @new_cart = Trade::Cart.where(options).find_or_create_by(good_type: 'Factory::Production', aim: 'use')
      @new_cart.migrate_from(@cart)
      @new_cart.compute_amount!
      @new_cart.save
    end

    private
    def set_cart
      @cart = current_member.agent_carts.find(params[:id])
    end

    def set_contact
      @cart.contact || @cart.build_contact
    end

    def cart_params
      _p = params.fetch(:cart, {}).permit(
        :address_id,
        :auto,
        contact_attributes: [:id, :identity, :name, :extra]
      )
      _p[:contact_attributes].merge! organ_id: current_organ.id
      _p
    end

  end
end

