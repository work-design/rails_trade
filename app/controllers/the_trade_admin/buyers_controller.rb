class TheTradeAdmin::BuyersController < TheTradeAdmin::BaseController
  before_action :set_buyer, only: [:orders]

  def index
    @managers = Manager.where(id: current_manager.allow_ids)
    q_params = params.fetch(:q, {}).permit(:payment_strategy_id, :'crm_permits.manager_id', :'name-like').reverse_merge('orders.payment_status': ['unpaid', 'part_paid'], 'orders.state': 'active')
    @overdue_date = params.fetch(:q, {})['overdue_date-lte'] || Date.today

    @buyers = Buyer.unscoped.includes(:orders, :payment_strategy, :crm_permits).default_where(q_params).permit_with(the_role_user).page(params[:page])
  end

  def overdue
    @managers = Manager.where(id: current_manager.allow_ids)
    q_params = params.fetch(:q, {}).permit(:payment_strategy_id, :'crm_permits.manager_id', :'name-like').reverse_merge('orders.payment_status': ['unpaid', 'part_paid'], 'orders.state': 'active')
    @overdue_date = params.fetch(:q, {})['overdue_date-lte'] || Date.today

    @buyers = Buyer.unscoped.includes(:orders, :payment_strategy, :crm_permits).default_where(q_params).permit_with(the_role_user).page(params[:page])
  end

  def orders
    @orders = @buyer.orders.to_pay.order(overdue_date: :asc).page(params[:page])
    payment_method_ids = @buyer.payment_references.pluck(:payment_method_id)
    @payments = Payment.where(payment_method_id: payment_method_ids, state: ['init', 'part_checked'])
  end

  def remind
    Order.remind params[:order_ids].split(',')

    redirect_back fallback_location: admin_buyers_url
  end

  private
  def set_buyer
    @buyer = Buyer.find params[:id]
  end

end
