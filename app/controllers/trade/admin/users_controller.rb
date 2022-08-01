module Trade
  class Admin::UsersController < Admin::BaseController

    def index
      q_params = {
        'orders.organ_id': current_organ.id
      }

      @users = Auth::User.where.associated(:orders).default_where(q_params)
    end

    def overdue
      @managers = Manager.where(id: current_manager.allow_ids)
      q_params = params.fetch(:q, {}).permit(:payment_strategy_id, :'crm_permits.manager_id', :'name-like').reverse_merge('orders.payment_status': ['unpaid', 'part_paid'], 'orders.state': 'active')
      @overdue_date = params.fetch(:q, {})['overdue_date-lte'] || Date.today

      @buyers = Buyer.unscoped.includes(:orders, :payment_strategy, :crm_permits).default_where(q_params).permit_with(rails_role_user).page(params[:page])
    end

    def remind
      Order.remind params[:order_ids].split(',')
    end

    private
    def set_buyer
      @buyer = Buyer.find params[:id]
    end

  end
end
