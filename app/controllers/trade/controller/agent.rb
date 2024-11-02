module Trade
  module Controller::Agent
    extend ActiveSupport::Concern
    include Controller::Application

    def set_new_item
      @item = @cart.init_cart_item(params, agent_id: current_member.id)
    end

  end
end
