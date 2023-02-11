module Trade
  class In::PaymentsController < My::PaymentsController

    private
    def set_order
      @order = current_organ.member_orders.find params[:order_id]
    end

    def current_payee
      return @current_payee if defined?(@current_payee)

      if params[:appid]
        @current_payee = current_organ_domain.app_payees.find_by(appid: params[:appid])
      elsif current_wechat_app
        @current_payee = current_wechat_app.app_payees.take
      else
        @current_payee = current_organ_domain.app_payees.take
      end

      logger.debug "\e[35m  Current Payee: #{@current_payee&.id}  \e[0m"
      @current_payee
    end
  end
end

