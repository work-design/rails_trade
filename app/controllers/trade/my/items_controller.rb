module Trade
  class My::ItemsController < My::BaseController
    before_action :set_item, only: [:show, :update, :destroy, :actions, :untrial, :promote, :toggle, :finish]
    before_action :set_cart, only: [:create, :trial]
    before_action :set_new_item, only: [:create]
    before_action :set_card_template, only: [:trial]

    def create
      if @item.save
        if @item.aim_rent?
          @item.current_cart.add_purchase_item
        end

        response.headers['Access-Control-Allow-Origin'] = request.origin
        response.headers['Access-Control-Allow-Credentials'] = true

        state = Com::State.find_by(id: params[:state_uuid])
        if state.present? && state.referer.present?
          render :create, status: :created, locals: { url: state.referer }
        else
          render :create, status: :created
        end
      else
        render :new, status: :unprocessable_entity, locals: { model: @item }
      end
    end

    def trial
      @cart.add_purchase_item(card_template: @card_template)
    end

    def untrial
      @item.untrial
    end

    def promote
      render layout: false
    end

    def toggle
      if @item.status_init?
        @item.status = 'checked'
      elsif @item.status_checked?
        @item.status = 'init'
      end

      @item.save
    end

    def finish
      @item.rent_finish_at = Time.current
      @item.save
    end

    def destroy
      @item.current_cart.checked_items.destroy(params[:id])
    end

    private
    def set_item
      @item = current_user.items.find params[:id]
    end

    def set_new_item
      options = {}
      options.merge! client_params
      options.merge! params.permit(:good_type, :good_id, :aim, :produce_on, :scene_id)

      @item = @cart.checked_items.find_or_initialize_by(options)
      @item.assign_attributes params.permit(:station_id, :desk_id, :current_cart_id)
      @item.number = @item.number.to_i + params[:number].to_i if @item.persisted?
    end

    def set_cart
      if params[:current_cart_id]
        @cart = Cart.find params[:current_cart_id]
      else
        options = {}
        options.merge! default_form_params
        options.merge! client_params
        @cart = Trade::Cart.where(options).find_or_create_by(good_type: params[:good_type], aim: params[:aim].presence || 'use')
      end
    end

    def set_card_template
      @card_template = CardTemplate.find params[:card_template_id]
    end

    def item_params
      params.fetch(:item, {}).permit(
        :number,
        :desk_id,
        :current_cart_id
      )
    end

  end
end
