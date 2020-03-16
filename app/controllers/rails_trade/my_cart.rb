module RailsTrade::MyCart
  extend ActiveSupport::Concern
  included do
    helper_method :current_cart
  end

  def current_cart
    return @current_cart if defined? @current_cart
    if current_user
      @current_cart = current_user.carts.default_where(default_params).find_or_create_by(default: true)
    else
      @current_cart = Cart.find_or_create_by(default_form_params.merge(session_id: session.id.to_s))
    end
  end

end
