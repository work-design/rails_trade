module Trade
  class Admin::TradeItemsController < Admin::BaseController
    #before_action :set_trade_items, only: [:index, :create, :only, :total]
    before_action :set_trade_item, only: [:show, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:cart_id, :order_id, :good_type, :good_id, :address_id, :status)

      #@checked_ids = @trade_items.checked.pluck(:id)
      @trade_items = TradeItem.default_where(q_params).page(params[:page]).per(params[:per])
    end

    def only
      unless params[:good_type] && params[:good_id]
        redirect_back(fallback_location: admin_trade_items_url) and return
      end

      good = params[:good_type].safe_constantize&.find_by(id: params[:good_id])
      if good.respond_to?(:user_id)
        @user = good.user
        @buyer = @user.buyer
        @trade_items = TradeItem.where(good_type: params[:good_type], good_id: params[:good_id], user_id: good.user_id)
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

    def create
      trade_item = @trade_items.unscope(where: :status).where(good_id: params[:good_id], good_type: params[:good_type]).first
      if trade_item.present?
        params[:quantity] ||= 0
        trade_item.checked = true
        trade_item.status = 'pending'
        trade_item.quantity = trade_item.quantity + params[:quantity].to_i
        trade_item.save
      else
        trade_item = @trade_items.build(good_id: params[:good_id], good_type: params[:good_type], quantity: params[:quantity], myself: false)
        trade_item.checked = true
        trade_item.save
      end

      @checked_ids = @trade_items.checked.pluck(:id)

      render 'index'
    end

    def total
      if params[:add_id].present?
        @add = @trade_items.find_by(id: params[:add_id])
        @add.update(checked: true)
      elsif params[:remove_id].present?
        @remove = @trade_items.find_by(id: params[:remove_id])
        @remove.update(checked: false)
      end

      response.headers['X-Request-URL'] = request.url
    end

    def doc
    end

    def update
      @trade_item.update(quantity: params[:quantity])
    end

    private
    def set_trade_item
      @trade_item = TradeItem.find(params[:id])
      @trade_items = TradeItem.where(user_id: @trade_item.user_id)
    end

    def set_additions
      if params[:buyer_type].present? && params[:buyer_id].present?
        @additions = TradeItem.checked_items(buyer_type: params[:buyer_type], buyer_id: params[:buyer_id])
      elsif params[:id]
        @additions = TradeItem.checked_items(buyer_type: @trade_item.buyer_type, buyer_id: @trade_item.buyer_id)
      else
        @additions = TradeItem.checked_items(buyer_type: nil, buyer_id: nil)
      end
    end

    def set_trade_items
      if params[:buyer_type].present? && params[:buyer_id].present?
        @buyer = params[:buyer_type].constantize.find params[:buyer_id]
        @trade_items = TradeItem.where(buyer_type: params[:buyer_type], buyer_id: params[:buyer_id])
      elsif params[:id].present?
        @trade_items = TradeItem.where(id: params[:id])
      else
        @trade_items = TradeItem.none
      end
      @trade_items = @trade_items.pending.default_where(params.permit(:good_type, :myself, :id))
    end

    def trade_item_params
      params.require(:trade_item).permit(
        id: [],
        single_price: [],
        amount: [],
        total_price: []
      )
    end

  end
end
