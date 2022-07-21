module Trade
  class OrdersController < BaseController
    before_action :set_order, only: [:qrcode]

    def qrcode
      redirect_to({ controller: 'trade/my/orders', action: 'show', id: params[:id], host: @order.organ.host }, allow_other_host: true)
    end

    private
    def set_order
      @order = Order.find params[:id]
    end

  end
end
