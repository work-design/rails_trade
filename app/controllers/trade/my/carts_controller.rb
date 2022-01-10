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
      trade_item = current_cart.get_trade_item(params[:good_type], params[:good_id], params[:number], params[:produce_plan_id])
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
        :current,
        :auto
      )
    end

  end
end
