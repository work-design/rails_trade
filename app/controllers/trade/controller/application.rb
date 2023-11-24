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
      options.merge! params.permit(:good_id, :produce_on, :scene_id)
      options.compact_blank!

      @item = @cart.find_item(**options) || @cart.items.build(options)
      @item.status = 'checked'
      @item.assign_attributes params.permit(['station_id', 'desk_id', 'current_cart_id'] & Item.column_names)
      @item.number = @item.number.to_i + (params[:number].presence || 1).to_i if @item.persisted?
    end

  end
end
