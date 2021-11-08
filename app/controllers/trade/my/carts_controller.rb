module Trade
  class My::CartsController < My::BaseController

    def show
      q_params = {
        status: ['init', 'checked']
      }
      if params[:address_id].present?
        current_cart.update address_id: params[:address_id]
      end

      @trade_items = current_cart.trade_items.includes(produce_plan: :scene).default_where(q_params).page(params[:page])
      @checked_ids = current_cart.trade_items.default_where(q_params).unscope(where: :status).checked.pluck(:id)
    end

    def add
      trade_item = current_cart.trade_items.find(&->(i){ i.good_id.to_s == params[:good_id] && i.good_type == params[:good_type] && i.produce_plan_id.to_s == params[:produce_plan_id].to_s }) ||
        current_cart.trade_items.build(good_id: params[:good_id], good_type: params[:good_type], produce_plan_id: params[:produce_plan_id])
      if trade_item.persisted? && trade_item.checked?
        params[:number] ||= 1
        trade_item.number += params[:number].to_i
      elsif trade_item.persisted? && trade_item.init?
        trade_item.status = 'checked'
        trade_item.number = 1
      else
        trade_item.status = 'checked'
      end
      trade_item.save

      @trade_items = current_cart.trade_items.page(params[:page])
      @checked_ids = current_cart.trade_items.checked.pluck(:id)
    end

    def addresses
      @addresses = current_user.addresses.order(id: :asc)
    end

    def list
      @members = current_user.members.includes(:organ)
    end

    def promote
    end

    def current
      p = {
        member_id: cart_params[:member_id]
      }.merge! default_form_params
      @cart = current_user.carts.find_or_initialize_by(p)
      @cart.current = true

      @cart.save
    end

    def edit
    end

    def update
      current_cart.assign_attributes(cart_params)

      if current_cart.save
        render :update
      else
        render :edit, locals: { model: current_cart }, status: :unprocessable_entity
      end
    end

    private
    def cart_params
      params.fetch(:cart, {}).permit(
        :address_id,
        :member_id,
        :current
      )
    end

  end
end
