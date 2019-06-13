class Trade::My::BaseController < RailsTrade.config.my_controller.constantize
  skip_before_action :verify_authenticity_token#, if: -> { request.content_type == 'application/json' }
  helper_method :current_buyer, :current_cart

  def current_cart
    if current_user
      @current_cart = current_user.carts.default
    else
      @current_cart = Cart.find_or_create_by(session_id: session.id)
    end
  end
  
  def current_buyer
    current_cart.buyer
  end

end
