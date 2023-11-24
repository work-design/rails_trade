module Trade
  class Admin::ItemsController < Admin::BaseController
    before_action :set_item, only: [
      :show, :update, :destroy, :actions,
      :print, :compute, :carts, :toggle, :untrial
    ]
    before_action :set_new_item, only: [:create]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:cart_id, :order_id, :good_type, :good_id, :aim, :address_id, :status)

      @items = Item.includes(:user, :item_promotes).default_where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
    end

    def carts
      @carts = @item.carts.includes(:user, :member)
    end

    def only
      unless params[:good_type] && params[:good_id]
        redirect_back(fallback_location: admin_items_url) and return
      end

      good = params[:good_type].safe_constantize&.find_by(id: params[:good_id])
      if good.respond_to?(:user_id)
        @user = good.user
        @buyer = @user.buyer
        @items = Item.where(good_type: params[:good_type], good_id: params[:good_id], user_id: good.user_id)
      end

      @item = @items.where(good_id: params[:good_id], good_type: params[:good_type]).first
      if @item.present?
        params[:quantity] ||= 0
        @item.checked = true
        @item.quantity = @item.quantity + params[:quantity].to_i
        @item.save
      else
        @item = @items.build(good_id: params[:good_id], good_type: params[:good_type], quantity: params[:quantity])
        @item.checked = true
        @item.save
      end

      @additions = @item.total

      render 'only'
    end

    def toggle
      if @item.status_init?
        @item.status = 'checked'
      elsif @item.status_checked?
        @item.status = 'init'
      end

      @item.save
    end

    def compute
      @item.compute_present_duration!(Time.current)
    end

    def print
      @item.print
    end

    def trial
      @cart.add_purchase_item(card_template: @card_template)
    end

    def untrial
      @item = @cart.trial_card_items.load.find params[:id]
      @item.untrial
    end

    private
    def set_cart
      if params[:current_cart_id].present?
        @cart = Cart.find params[:current_cart_id]
      elsif item_params[:current_cart_id].present?
        @cart = Cart.find item_params[:current_cart_id]
      else
        options = { agent_id: current_member.id }
        options.merge! default_form_params
        options.merge! user_id: nil, member_id: nil, client_id: nil
        @cart = Trade::Cart.where(options).find_or_create_by(good_type: params[:good_type], aim: params[:aim].presence || 'use')
      end
    end

    def set_item
      @item = Item.where(default_params).find params[:id]
    end

    def set_new_item
      options = {}
      options.merge! params.permit(:good_type, :good_id, :aim, :number, :produce_on, :scene_id, :current_cart_id)

      @item = Item.new(options)
    end

    def item_params
      params.fetch(:item, {}).permit(
        :number,
        :rent_estimate_finish_at
      )
    end

  end
end
