class TheTradeAdmin::BuyersController < TheTradeAdmin::BaseController
  before_action :set_buyer, only: [:orders]

  def index
    @managers = Manager.where(id: current_manager.allow_ids)
    q_params = params.fetch(:q, {}).permit(:payment_strategy_id, :'crm_permits.manager_id', :buyer_id).reverse_merge('orders.payment_status': ['unpaid', 'part_paid'], 'orders.state': 'active')
    @overdue_date = params.fetch(:q, {})['overdue_date-lte'] || Date.today

    #binding.pry

    @buyers = Buyer.unscoped.includes(:orders, :crm_permits)
      .default_where(q_params)
      .page(params[:page])
  end

  def overdue
    @managers = Manager.where(id: current_manager.allow_ids)
    q_params = params.fetch(:q, {}).permit!.reverse_merge('overdue_date-lte': Date.today, payment_status: ['unpaid', 'part_paid'], state: 'active')

    @orders = Order.unscoped.includes(:buyer, :payment_strategy, :crm_performs).select('SUM(`orders`.`amount`) as sum_amount, COUNT(`orders`.`id`) as count_id, `orders`.`buyer_id`, `orders`.`overdue_date`, `orders`.`payment_strategy_id`')
      .group(:buyer_id)
      .permit_with(the_role_user)
      .credited
      .default_where(q_params)
      .order(overdue_date: :asc)
      .page(params[:page])
  end

  def orders
    @orders = @buyer.orders.to_pay.order(overdue_date: :asc).page(params[:page])
    payment_method_ids = PaymentReference.where(buyer_id: params[:buyer_id]).pluck(:payment_method_id)
    @payments = Payment.where(payment_method_id: payment_method_ids, state: ['init', 'part_checked'])
  end

  def remind
    Order.remind params[:order_ids].split(',')

    redirect_back fallback_location: admin_buyers_url
    #render head: :no_content
  end

  private
  def set_buyer
    @buyer = Buyer.find params[:id]
  end

end
