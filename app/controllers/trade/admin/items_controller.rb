module Trade
  class Admin::ItemsController < Admin::BaseController
    before_action :set_trade_item, only: [:show, :update, :destroy, :actions, :carts]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:cart_id, :order_id, :good_type, :good_id, :aim, :address_id, :status)

      @trade_items = Item.includes(:item_promotes).default_where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
    end

    def carts
      @carts = @trade_item.carts.includes(:user, :member)
    end

    def only
      unless params[:good_type] && params[:good_id]
        redirect_back(fallback_location: admin_trade_items_url) and return
      end

      good = params[:good_type].safe_constantize&.find_by(id: params[:good_id])
      if good.respond_to?(:user_id)
        @user = good.user
        @buyer = @user.buyer
        @trade_items = Item.where(good_type: params[:good_type], good_id: params[:good_id], user_id: good.user_id)
      end

      @trade_item = @trade_items.where(good_id: params[:good_id], good_type: params[:good_type]).first
      if @trade_item.present?
        params[:quantity] ||= 0
        @trade_item.checked = true
        @trade_item.quantity = @trade_item.quantity + params[:quantity].to_i
        @trade_item.save
      else
        @trade_item = @trade_items.build(good_id: params[:good_id], good_type: params[:good_type], quantity: params[:quantity])
        @trade_item.checked = true
        @trade_item.save
      end

      @additions = @trade_item.total

      render 'only'
    end

    def total
      if params[:add_id].present?
        @add = @trade_items.find_by(id: params[:add_id])
        @add.update(checked: true)
      elsif params[:remove_id].present?
        @remove = @trade_items.find_by(id: params[:remove_id])
        @remove.update(checked: false)
      end
    end

    def doc
    end

    private
    def set_trade_item
      @trade_item = Item.where(default_params).find params[:id]
    end

    def trade_item_params
      params.fetch(:trade_item, {}).permit(
        :number,
        :current_cart_id
      )
    end

  end
end
