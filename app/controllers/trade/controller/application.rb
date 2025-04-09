module Trade
  module Controller::Application
    extend ActiveSupport::Concern

    included do
      helper_method :current_cart_count
    end

    private
    def current_cart
      return @current_cart if defined? @current_cart
      if params[:current_cart_id].present?
        @current_cart = Trade::Cart.find params[:current_cart_id]
      elsif params.dig(:item, :current_cart_id).present?
        @current_cart = Trade::Cart.find params.dig(:item, :current_cart_id)
      end
    end

    def current_cart_count(good_type: 'Factory::Production')
      if current_cart
        current_cart.items.select(&->(i){ i.persisted? && i.good_type == good_type }).size
      else
        0
      end
    end

    def set_new_item
      @item = @cart.init_cart_item(params)
    end

    def set_cart_item
      @item = @cart.items.load.find params[:id]
      @item.current_cart = @cart
    end

  end
end
