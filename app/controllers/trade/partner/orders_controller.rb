module Trade
  class Partner::OrdersController < Panel::OrdersController
    include Org::Controller::Admin
    before_action :require_org_member

    def index
      q_params = { organ_id: current_organ.organ_ids }
      q_params.merge! params.permit(:id, :uuid, :user_id, :member_id, :payment_status, :state, :payment_type)

      @orders = Order.includes(:organ, :user, :member, :member_organ).default_where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
      @grouped_orders = @orders.group_by { |i| i.created_at.to_date }
    end

  end
end
