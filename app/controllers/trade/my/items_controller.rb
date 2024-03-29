module Trade
  class My::ItemsController < My::BaseController
    before_action :set_cart, only: [:create, :update, :destroy, :toggle, :trial, :untrial]
    before_action :set_cart_item, only: [:update, :destroy, :promote, :toggle, :finish]
    before_action :set_new_item, only: [:create]
    before_action :set_item, only: [:show, :edit, :order_edit, :order_update, :actions]
    before_action :set_card_template, only: [:trial]
    after_action :support_cors, only: [:create]

    def index
      q_params = {}
      q_params.merge! params.permit('extra/product_taxon_id', 'holds_count', 'holds_count-gt')

      @items = current_user.items.default_where(q_params).page(params[:page])
    end

    def create
      if @item.save
        state = Com::State.find_by(id: params[:state_uuid])
        if state.present? && state.referer.present?
          render :create, status: :created, locals: { url: state.referer }
        else
          render :create, status: :created
        end
      else
        render :new, locals: { model: @item }, status: :unprocessable_entity
      end
    end

    def trial
      @cart.add_purchase_item(card_template: @card_template)
    end

    def untrial
      @item = @cart.trial_card_items.load.find params[:id]
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

    def order_update
      @item.assign_attributes ordered_item_params
      @item.save
    end

    def finish
      @item.rent_finish_at = Time.current
      @item.save
    end

    def destroy
      @cart.items.destroy(@item)
    end

    private
    def set_cart
      if current_cart
        @cart = current_cart
      else
        options = { user_id: current_user.id, member_id: nil, client_id: nil }
        options.merge! default_form_params
        @cart = Trade::Cart.where(options).find_or_create_by(good_type: params[:good_type], aim: params[:aim].presence || 'use')
      end
    end

    def set_item
      @item = current_user.items.find params[:id]
    end

    def set_card_template
      @card_template = CardTemplate.find params[:card_template_id]
    end

    def item_params
      params.fetch(:item, {}).permit(
        :number,
        :note,
        :desk_id
      )
    end

    def ordered_item_params
      params.fetch(:item, {}).permit(
        :note
      )
    end

  end
end
