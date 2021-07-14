module Trade
  module Controller::Application
    extend ActiveSupport::Concern

    included do
      helper_method :current_cart, :current_cart_count, :current_card
    end

    def current_cart
      return @current_cart if @current_cart

      if current_user
        @current_cart = current_user.carts.find_or_create_by(default_form_params)
      end
      logger.debug "  \e[35mCurrent Trade cart: #{@current_cart&.id}\e[0m"
      @current_cart
    end

    def current_card
      platform = request.headers['OS'].to_s.downcase
      if defined?(current_user) && current_user
        current_user.init_wallet(platform)
      end
    end

    def current_cart_count
      if current_cart
        current_cart.trade_items.where(status: ['init', 'checked']).count
      else
        0
      end
    end

  end
end
