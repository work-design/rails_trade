module Trade
  module Controller::Me
    extend ActiveSupport::Concern

    included do
      helper_method :current_cart, :current_cart_count
    end

    def current_cart
      return @current_cart if @current_cart

      options = {
        member_id: current_member.id,
        organ_id: nil
      }
      @current_cart = current_user.carts.find_by(options) || current_user.carts.create(options)

      logger.debug "\e[33m  Current Trade cart: #{@current_cart&.id}  \e[0m"
      @current_cart
    end

  end
end
