module Trade
  class My::PackagesController < My::BaseController
    before_action :set_order
    before_action :set_package, only: [:show]

    private
    def set_order
      @order = Order.find params[:order_id]
    end

    def set_package
      @package = @order.packages.find params[:id]
    end

  end
end
