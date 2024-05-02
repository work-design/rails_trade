module Trade
  module Controller::Application
    extend ActiveSupport::Concern

    included do
      helper_method :current_cart_count
    end

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
      options = {}
      options.merge! params.permit(:good_id, :dispatch, :produce_on, :scene_id)
      options.compact_blank!

      @item = @cart.find_item(**options) || @cart.items.build(options)
      @item.status = 'checked'
      @item.assign_attributes params.permit(['station_id', 'desk_id', 'current_cart_id'] & Item.column_names)
      if @item.persisted?
        @item.number = params[:number].presence || 1
      end
    end

    def set_item
      @item = @cart.items.load.find params[:id]
      @item.current_cart = @cart
    end

  end
end
