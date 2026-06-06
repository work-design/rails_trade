module Trade
  class OrdersController < BaseController
    before_action :set_order, only: [:show, :qrcode]
    before_action :require_user, only: [:qrcode]

    def qrcode
      if @order.user_id == current_user.id
        redirect_to({ controller: 'trade/my/orders', action: 'show', id: params[:id], host: @order.organ.host }, allow_other_host: true)
      elsif current_user.members.pluck(:organ_id).include? @order.organ_id
        redirect_to({ controller: 'trade/admin/orders', action: 'show', id: @order.id, host: @order.organ.admin_host }, allow_other_host: true)
      elsif @order.generate_mode == 'by_from'
        redirect_to({ controller: 'trade/board/orders', action: 'show', id: params[:id] })
      elsif @order.can_pay?
        render 'payment_types'
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
