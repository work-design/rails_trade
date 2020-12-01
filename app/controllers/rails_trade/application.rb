module RailsTrade::Application
  extend ActiveSupport::Concern

  included do
    helper_method :current_cart, :current_cart_count
  end

  def current_cart
    if defined? @current_cart
      logger.debug " ==========> Current cart: #{@current_cart&.id}"
      return @current_cart
    end

    if current_user
      @current_cart = current_user.carts.find_or_create_by(default_form_params)
    end
    logger.debug " ==========> Current cart: #{@current_cart&.id}"
    @current_cart
  end

  def current_cart_count
    if current_cart
      current_cart.trade_items.where(status: ['init', 'checked']).count
    else
      0
    end
  end

end
