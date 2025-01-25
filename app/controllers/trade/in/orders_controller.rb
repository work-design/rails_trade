module Trade
  class In::OrdersController < Admin::OrdersController
    include Controller::In
    before_action :set_order, only: [
      :show, :edit, :update, :destroy, :actions, :edit_organ,
      :payment_types, :payment_pending, :payment_confirm, :batch_receive
    ]
    before_action :set_providers, only: [:edit_organ]

    def index
      q_params = {}
      q_params.merge! params.permit(:id, :uuid, :user_id, :member_id, :payment_status, :state, :payment_type)

      @orders = current_organ.organ_orders.includes(:user, :member, :member_organ).default_where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
    end

    def payments
      q_params = {}
      q_params.merge! params.permit(:id, :payment_status, :uuid)

      @orders = Order.default_where(q_params).page(params[:page])
    end

    def payment_confirm
      @order.batch_pending_payments(payment_params)
      @order.save
    end

    def batch_receive
      @order.items.where(id: params[:ids].split(',')).each do |i|
        i.purchase_status = 'received'
        i.save
      end
    end

    def refund
      @order.apply_for_refund
    end

    private
    def set_order
      @order = current_organ.organ_orders.find(params[:id])
    end

    def set_new_order
      @order = current_organ.organ_orders.build(order_params)
    end

    def set_providers

    end

    def order_params
      _p = params.fetch(:order, {}).permit(
        :organ_id,
        :provide_id,
        :weight,
        :quantity,
        :payment_id,
        :payment_type,
        :address_id,
        :invoice_address_id,
        :note,
        :generate_mode,
        :current_cart_id,
        items_attributes: [:good_type, :good_id, :good_name, :source_id, :number, :single_price, :note],
        item_promotes_attributes: {}
      )
      _p.fetch(:items_attributes, {}).each do |_, v|
        v.merge! member_organ_id: current_organ.id
      end
      _p.merge! current_cart_id: params[:current_cart_id] if params[:current_cart_id]
      _p
    end

  end
end
