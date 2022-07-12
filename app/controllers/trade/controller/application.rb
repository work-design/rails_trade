module Trade
  module Controller::Application
    extend ActiveSupport::Concern

    included do
      helper_method :current_cart, :current_cart_count
    end

    def current_carts
      return @current_carts if @current_carts

      options = {}
      options.merge! default_form_params
      options.merge! client_params
      @current_carts = Cart.where(options)
    end

    def current_cart
      return @current_cart if @current_cart

      if current_user
        options = {}
        options.merge! default_form_params
        options.merge! member_id: current_member.id if current_member
        @current_cart = current_user.carts.find_or_create_by(options)
        @current_cart
      end
      logger.debug "\e[33m  Current Trade cart: #{@current_cart&.id}  \e[0m"
      @current_cart
    end

    def current_cart_count(good_type: 'Factory::Production')
      if current_cart
        current_cart.trade_items.select(&->(i){ i.persisted? && i.good_type == good_type }).size
      else
        0
      end
    end

  end
end
