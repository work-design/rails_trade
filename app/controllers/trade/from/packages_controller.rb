module Trade
  class From::PackagesController < My::PackagesController
    before_action :set_order
    before_action :set_package, only: [:show]

    def index
      @card_logs = @order.card_logs.page(params[:page])
    end

    private
    def set_order
      @order = Order.find params[:order_id]
    end

    def set_package
      @package = @order.packages.find params[:id]
    end

  end
end
