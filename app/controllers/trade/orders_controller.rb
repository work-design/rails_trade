module Trade
  class OrdersController < My::OrdersController
    before_action :set_order, only: [:payment_pending, :qrcode]

    def qrcode
      if @order.user_id == current_user.id
        redirect_to({ controller: 'trade/my/orders', action: 'show', id: params[:id], host: @order.organ.host }, allow_other_host: true)
      elsif current_user.members.pluck(:organ_id).include? @order.organ_id
        redirect_to({ controller: 'trade/admin/orders', action: 'show', id: @order.id, host: @order.organ.admin_host }, allow_other_host: true)
      elsif @order.generate_mode == 'by_from'
        redirect_to({ controller: 'trade/board/orders', action: 'show', id: params[:id] })
      elsif @order.can_pay?
        @order.init_wallet_payments
        set_wxpay
      else
        render 'err_not_found'
      end
    end

    private
    def set_order
      @order = Order.find params[:id]
    end

  end
end
