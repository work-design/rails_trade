module Trade
  class My::CartsController < My::BaseController

    def show
      q_params = {
        status: ['init', 'checked']
      }
      if params[:address_id].present?
        current_cart.update address_id: params[:address_id]
      end

      @trade_items = current_cart.trade_items.default_where(q_params).page(params[:page])
      @checked_ids = current_cart.trade_items.default_where(q_params).unscope(where: :status).checked.pluck(:id)
    end

    def add
      trade_item = current_cart.trade_items.where(status: ['init', 'checked']).find_by(good_id: params[:good_id], good_type: params[:good_type]) || current_cart.trade_items.build(good_id: params[:good_id], good_type: params[:good_type])
      if trade_item.persisted?
        params[:number] ||= 1
        trade_item.number += params[:number].to_i
      end
      trade_item.save

      @trade_items = current_cart.trade_items.where(status: ['init', 'checked']).page(params[:page])
      @checked_ids = current_cart.trade_items.checked.pluck(:id)

      redirect_to({ action: 'show' })
    end

    def addresses
      @addresses = current_user.addresses.order(id: :asc)
    end

    def list
      @members = current_user.members.group_by(&:organ)
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
        :address_id
      )
    end

  end
end
