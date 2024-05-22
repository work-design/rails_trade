module Trade
  module Controller::Agent
    extend ActiveSupport::Concern
    include Controller::Application

    included do
      layout 'agent'
    end

    def set_new_item
      @item = @cart.init_cart_item(params, agent_id: current_member.id)
    end

    class_methods do
      def local_prefixes
        [controller_path, 'agent', 'me']
      end
    end

  end
end
