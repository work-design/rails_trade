class Trade::My::BaseController < RailsTrade.config.my_controller.constantize
  helper_method :current_cart

  def current_cart
    if current_user
      @current_cart = current_user.carts.default_where(default_params).find_or_create_by(default: true)
    else
      @current_cart = Cart.find_or_create_by(default_params.merge(session_id: session.id))
    end
  end

end
