module RailsTrade::Application
  extend ActiveSupport::Concern

  included do
    helper_method :current_cart, :current_cart_count
  end

  def current_cart
    return @current_cart if defined? @current_cart

    if current_organ && current_user
      @current_cart = current_user.carts.find_or_create_by(organ_id: current_organ.id)
    elsif current_user
      @current_cart = current_user.total_cart || current_user.create_total_cart
    end
  end

  def current_cart_count
    if current_cart
      current_cart.trade_items.count
    else
      0
    end
  end

end
