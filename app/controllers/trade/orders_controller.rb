module Trade
  class OrdersController < BaseController
    before_action :set_order, only: [:qrcode]

    def qrcode
      if @order.generate_mode == 'by_from'
        redirect_to({ controller: 'trade/board/orders', action: 'show', id: params[:id] })
      else
        redirect_to({ controller: 'trade/my/orders', action: 'show', id: params[:id], host: @order.organ.host }, allow_other_host: true)
      end
    end

    private
    def set_order
      @order = Order.find params[:id]
    end

  end
end
