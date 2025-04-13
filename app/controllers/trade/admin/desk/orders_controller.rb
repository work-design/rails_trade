module Trade::Admin
  class Desk::OrdersController < OrdersController
    before_action :set_desk

    def index
      q_params = {
        state: ['init']
      }
      q_params.merge! default_params
      q_params.merge! params.permit(:cart_id, :order_id, :good_type, :good_id, :desk_id, :aim, :address_id, :status)

      @order_s = Order.default_where(q_params)
      @orders = @order_s.includes(:user, :items).order(id: :desc).page(params[:page]).per(params[:per])
    end

    def history
      q_params = {
        state: ['done']
      }
      q_params.merge! default_params
      q_params.merge! params.permit(:cart_id, :order_id, :good_type, :good_id, :desk_id, :aim, :address_id, :status, 'created_at-gte', 'created_at-lte')

      @order_s = Order.default_where(q_params)
      @orders = @order_s.includes(:user, :items).order(id: :desc).page(params[:page]).per(params[:per])
    end

    def done
      q_params = {
        state: 'init'
      }
      q_params.merge! default_params
      q_params.merge! params.permit(:cart_id, :order_id, :good_type, :good_id, :desk_id, :aim, :address_id, :status)

      @orders = Order.default_where(q_params).update_all state: 'done'
    end

    private
    def set_desk
      @desk = Space::Desk.default_where(default_params).find params[:desk_id]
    end

  end
end
