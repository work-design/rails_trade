module Trade
  class Admin::ItemsController < Admin::BaseController
    before_action :set_item, only: [:show, :update, :destroy, :actions, :carts, :toggle]
    before_action :set_new_item, only: [:create]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:cart_id, :order_id, :good_type, :good_id, :aim, :address_id, :status)

      @items = Item.includes(:item_promotes).default_where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
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

    def doc
    end

    def toggle
      if @item.status_init?
        @item.status = 'checked'
      elsif @item.status_checked?
        @item.status = 'init'
      end

      @item.save
    end

    private
    def set_item
      @item = Item.where(default_params).find params[:id]
    end

    def set_new_item
      options = {}
      options.merge! params.permit(:good_type, :good_id, :aim, :number, :produce_on, :scene_id, :fetch_oneself, :current_cart_id)

      @item = Item.new(options)
    end

    def item_params
      params.fetch(:item, {}).permit(
        :number,
        :current_cart_id
      )
    end

  end
end
